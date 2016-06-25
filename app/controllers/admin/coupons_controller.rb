class Admin::CouponsController < ApplicationController
  layout "admin"
  before_filter :redirect_to_ssl, :check_authentication

  def index
    @coupons = Coupon.find_by_sql("select count(*) as count, i.id, i.code, i.coupon, i.description, i.use_limit, i.used_count, i.amount, i.percentage, i.product_code from coupons i group by i.id,i.code,i.coupon,i.description,i.use_limit,i.used_count,i.product_code,i.amount,i.percentage order by lower(i.code)")
  end

  def show
    @coupons = Coupon.where(:code => params[:id])
  end

  def new
    @coupon = Coupon.new
    names = Coupon.pluck(:code).uniq
    @coupon_names = names.sort_by(&:downcase)
  end

  def edit
    @coupon = Coupon.find(params[:id])
    names = Coupon.pluck(:code).uniq
    @coupon_names = names.sort_by(&:downcase)
  end

  def create
    if params[:coupon]
      form = params[:coupon]

      if form[:code].blank?
        flash[:notice] = 'A Name is required!'
        redirect_to :action => 'new' and return
      end

      coupons = Coupon.where(:code => form[:code])
      if coupons.size > 0
        flash[:notice] = 'Please choose a unique Name'
        redirect_to :action => 'new' and return
      end

      if form[:description].blank?
        flash[:notice] = 'A Description is required!'
        redirect_to :action => 'new' and return
      end

      if !form[:coupon].blank?
        generate_coupon(form[:code], form[:product_code], form[:description],
                        form[:amount], form[:percentage], form[:use_limit], form[:coupon].gsub(/[^0-9a-z ]/i, '').upcase)
      else
        flash[:notice] = 'Whoops try again!'
        redirect_to :action => 'new' and return
      end

      flash[:notice] = 'Coupons generated'
    end

    redirect_to admin_coupons_path
  end

  def update
    @coupon = Coupon.find(params[:id])
    coupons = Coupon.where(:code => params[:code])
    if coupons.size > 0
      flash[:notice] = 'Please choose a unique Name'
      redirect_to :action => 'edit' and return
    end

    if @coupon.update_attributes(params.require(:coupon).permit(:code, :coupon, :description, :product_code, :amount, :percentage, :use_limit))
      redirect_to admin_coupons_path, notice: 'Coupon was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @coupon = Coupon.find(params[:id])
    @coupon.destroy

    redirect_to admin_coupons_url
  end

  private
    def generate_coupon(code, product_code, description, amount, percentage, use_limit, coupon_code)
      coupon = Coupon.new
      coupon.code = code
      coupon.product_code = product_code
      coupon.description = description
      coupon.amount = amount
      coupon.percentage = percentage
      coupon.use_limit = use_limit
      coupon.coupon = coupon_code
      coupon.creation_time = Time.now
      coupon.save
    end
end
