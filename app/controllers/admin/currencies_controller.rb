class Admin::CurrenciesController < ApplicationController

  layout "admin"

  before_filter :redirect_to_ssl, :check_authentication

  # GET /currencies
  # GET /currencies.xml
  def index
    @currencies = Currency.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @currencies.to_xml }
    end
  end

  # GET /currencies/new
  def new
    @currency = Currency.new
    @supported_currencies = supported_currencies
  end

  # GET /currencies/1;edit
  def edit
    @currency = Currency.find(params[:id])
    @supported_currencies = supported_currencies
  end

  # POST /currencies
  # POST /currencies.xml
  def create
    @currency = Currency.new(params[:currency])

    respond_to do |format|
      if @currency.save
        flash[:notice] = 'Currency was successfully created.'
        format.html { redirect_to admin_currencies_url }
        format.xml  { head :created, :location => admin_currencies_url }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @currency.errors.to_xml }
      end
    end
  end

  # PUT /currencies/1
  # PUT /currencies/1.xml
  def update
    @currency = Currency.find(params[:id])

    respond_to do |format|
      if @currency.update_attributes(params[:currency])
        flash[:notice] = 'Currency was successfully updated.'
        format.html { redirect_to admin_currencies_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @currency.errors.to_xml }
      end
    end
  end

  # DELETE /currencies/1
  # DELETE /currencies/1.xml
  def destroy
    @currency = Currency.find(params[:id])
    @currency.destroy

    respond_to do |format|
      format.html { redirect_to admin_currencies_url }
      format.xml  { head :ok }
    end
  end

  def countries_for_currency
    render :text => Currency::default_countries_for_currency(params[:currency]).join(',')
  end

  private
    def supported_currencies
      require 'csv'
      currencies = []
      CSV.open("#{Rails.root}/config/currencies.csv", "r") { |r| currencies += r[3].split('|') }
      return currencies.sort.uniq
    end

end
