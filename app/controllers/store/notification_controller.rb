require 'base64'
require 'xmlsimple'

def _xmlval(hash, key)
  if hash[key] == {}
    nil
  else
    hash[key]
  end
end


class Store::NotificationController < ApplicationController

  ## Google Checkout notification

  def gcheckout
    # Check HTTP basic authentication first
    my_auth_key = Base64.encode64($STORE_PREFS['gcheckout_merchant_id'] + ':' + $STORE_PREFS['gcheckout_merchant_key']).strip()
    http_auth = request.headers['HTTP_AUTHORIZATION']
    if http_auth.nil? || http_auth.split(' ')[0] != 'Basic' || http_auth.split(' ')[1] != my_auth_key then
      logger.warn('Got unauthorized Google Checkout notification')
      render :text => 'Unauthorized', :status => 401 and return
    end

    # Authenticated. Parse the xml now
    notification = XmlSimple.xml_in(request.raw_post, 'KeepRoot' => true, 'ForceArray' => false)

    notification_name = notification.keys[0]
    notification_data = notification[notification_name]

    case notification_name
    when 'new-order-notification'
      process_new_order_notification(notification_data)

    when 'charge-amount-notification'
      process_charge_amount_notification(notification_data)
      # Ignore the other notifications
      #   when 'order-state-change-notification'
      #   when 'risk-information-notification'
    end

    render :text => ''
  end
    
  def paypal_wps

    if params[:receiver_email] != $STORE_PREFS['paypal_wps_email_address']
      logger.warn("Got request to PayPal IPN with invalid receiver email from #{request.remote_addr || request.remote_ip}")
      render :text => 'Unauthorized', :status => 401
      return
    end
    
    # Call PayPal to validate
    begin
      validate_args = params.dup
      validate_args['cmd'] = '_notify-validate'

      if ENV['RAILS_ENV'] == 'test'
        body = params[:notify_validate]
      else
        require 'net/http'
        require 'net/https'
        url = URI.parse($STORE_PREFS['paypal_wps_url'])
        req = Net::HTTP::Post.new(url.path)
        req.set_form_data(validate_args)
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        body = http.start { |h| (res=h.request(req)).kind_of? Net::HTTPSuccess and res.read_body or nil }
      end
      
      #when setting up button in PayPal, make sure "Donation ID" is left Blank!!!   
      info = params[:item_number]
      if info == nil
        render :text => "Donation processed", :status => 200
        return
      end
      
      if !body 
        logger.warn("Unable to authorise request to PayPal IPN for customer #{params[:payer_email]}")
        render :text => 'Unauthorized', :status => 401
        return
      end
      if body.strip != 'VERIFIED'
        logger.warn("Unauthorised request to PayPal IPN from #{request.remote_addr || request.remote_ip}")
        render :text => 'Unauthorized', :status => 401
        return
      end
    rescue Exception => e
      logger.warn("Exception while posting PayPal IPN validation: #{e.inspect} for customer #{params[:payer_email]}")
      render :text => 'Internal error', :status => 500
      return
    end
    
    if params[:txn_type] != 'web_accept'
      logger.warn("Non-web payment IPN type for customer #{params[:payer_email]}")
      render :text => 'Ignoring non web_accept type', :status => 200
      return
    end
    
    order = Order.find_by_transaction_number_and_payment_type(params[:txn_id], 'PayPal')
    
    if order && order.status == 'C'
      logger.warn("Duplicate IPN with transaction id #{params[:txn_id]}")
      render :text => 'Ignoring IPN duplicate', :status => 200
      return
    end
    
    if !order
      
      #when setting up button in PayPal, make sure "Donation ID" is left Blank!!!   
      info = params[:item_number]
      if info == nil
        render :text => "Donation processed", :status => 200
        return
      end
      
      order = Order.new
      order.status = 'S'
      order.first_name = params[:first_name]
      order.last_name = params[:last_name]
      order.licensee_name = order.first_name + " " + order.last_name
      order.email = params[:payer_email]
    
      order.address1 = params[:address_street] 
      order.address2 = '' 
      order.city     = params[:address_city] 
      order.country  = params[:address_country_code] 
      order.zipcode  = params[:address_zip] 
      order.state    = params[:address_state]
    
      if !order.country
        # No address given to us by PayPal; try the other field
        order.country = params[:residence_country] or 'XX'
      end
    
      order.transaction_number = params[:txn_id]
      order.payment_type = "PayPal"
      order.order_time = Time.now
      order.currency = params[:mc_currency]
      
      if !order.tinydecode params[:item_number]
      
        #when setting up button in PayPal, make sure "Donation ID" is left Blank!!! 
        if params[:item_number] == ''
          logger.warn("Donation for #{params[:item_name]} from customer #{params[:first_name]} #{params[:last_name]}")
          render :text => 'Donation', :status => 200
          return
        else
          logger.warn("Unable to decode order from item_number parameter, #{params[:item_number]} for customer #{params[:payer_email]}")
          order.status = 'F'
          order.failure_reason = "Unable to decode order from item_number parameter, #{params[:item_number]}"
          order.finish_and_save()
          render :text => 'Unable to decode order', :status => 200
          return   
        end
      end
    end
    
    if params[:mc_gross].to_f < order.total
      
      #when setting up button in PayPal, make sure "Donation ID" is left Blank!!!   
      info = params[:item_number]
      if info == nil
        render :text => "Donation processed", :status => 200
        return
      end
      
      logger.warn("Payment of #{"%01.2f" % params[:mc_gross]} #{params[:mc_currency]} is less than order price, #{"%01.2f" % order.total} #{params[:mc_currency]}, for customer #{params[:payer_email]}")
      order.status = 'F'
      order.failure_reason = "Payment of #{"%01.2f" % params[:mc_gross]} #{params[:mc_currency]} is less than order price, #{"%01.2f" % order.total} #{params[:mc_currency]}"
      order.finish_and_save()
      render :text => 'Payment less than order price', :status => 200
      return
    end

    
    case params[:payment_status]
    when 'Completed'
        
      #when setting up button in PayPal, make sure "Donation ID" is left Blank!!!
      #also check to make sure order source is not a promo 
      info = params[:item_number]
      source = params[:source]
      if info == nil && source != nil
        render :text => "Donation processed", :status => 200
        return
      end
      
      order.status = 'C'
      order.finish_and_save()
      Thread.new do
        OrderMailer.thankyou(order).deliver
      end
      render :text => "Order processed", :status => 201
      return
        
    when 'Pending'
      order.status = 'P'
      order.save
      
    when 'Denied'
      order.status = 'F'
      order.failure_reason = 'You denied the payment'
      order.finish_and_save
        
    when 'Failed'
      order.status = 'F'
      order.failure_reason = 'The payment has failed'
      order.finish_and_save
    end

    render :text => "Update processed", :status => 200
    
  end
    

  private
  def process_new_order_notification(n)
    order = Order.find(Integer(n['shopping-cart']['merchant-private-data']['order-id']))

    return if order == nil or order.payment_type != 'Google Checkout'

    ba = n['buyer-billing-address']

    if ba['structured-name']
      order.first_name = _xmlval(ba['structured-name'], 'first-name')
      order.last_name = _xmlval(ba['structured-name'], 'last-name')
    else
      words = ba['contact-name'].split(' ')
      order.first_name = words.shift
      order.last_name = words.join(' ')
    end

    order.email = _xmlval(ba, 'email')
    if order.email == nil # This shouldn't happen, but just in case
      order.status = 'F'
      order.failure_reason = 'Did not get email from Google Checkout'
      order.finish_and_save()
      return
    end

    order.address1 = _xmlval(ba, 'address1')
    order.address2 = _xmlval(ba, 'address2')
    order.city     = _xmlval(ba, 'city')
    order.company  = _xmlval(ba, 'company-name')
    order.country  = _xmlval(ba, 'country-code')
    order.zipcode  = _xmlval(ba, 'postal-code')
    order.state    = _xmlval(ba, 'region')

    order.transaction_number = n['google-order-number']

    order.save()

    order.subscribe_to_list() if n['buyer-marketing-preferences']['email_allowed'] == 'true'

    order.send_to_google_add_merchant_order_number_command()
  end

  private
  def process_charge_amount_notification(n)
    order = Order.find_by_transaction_number_and_payment_type(n['google-order-number'], 'Google Checkout')

    return if order == nil or order.status == 'C'

    order.status = 'C'
    order.finish_and_save()
    Thread.new do
      OrderMailer.deliver_thankyou(order) if is_live?()
    end

    order.send_to_google_archive_order_command()
  end

end
