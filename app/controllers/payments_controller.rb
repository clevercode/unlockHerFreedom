class PaymentsController < ApplicationController

  before_filter :redirect_to_home, only: [:new, :index, :show, :edit, :update, :show]

  def redirect_to_home
    redirect_to '/'
  end

  def index
    @payments = Payment.all

    respond_to do |format|
      format.html
      format.json { render json: @payments }
    end
  end

  def show
    @payment = Payment.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @payment }
    end
  end

  def new
    @payment = Payment.new

    respond_to do |format|
      format.html
      format.json { render json: @payment }
    end
  end

  def edit
    @payment = Payment.find(params[:id])
  end

  def create
    @payment = Payment.new(params[:payment])

    # get the credit card details submitted by the form
    token = params[:stripeToken]

    # create the charge on Stripe's servers - this will charge the user's card
    charge = Stripe::Charge.create(
      :amount => params[:amount], # amount in cents
      :currency => "usd",
      :card => token,
      :description => "#{params[:name]}: #{params[:email]}"
    )

    if charge.id
      # Tell the UserMailer to send a welcome Email after save
      UserMailer.confirmation_email(@payment).deliver

      redirect_to '/', flash: { notice: 'Thank you for your donation! You\'ll recieve an email confirmation shortly.' }
    else
      redirect_to '/', flash: { alert: 'Sorry, there was problem with your donation. Please try again.' }
    end
  end

  def update
    @payment = Payment.find(params[:id])

    respond_to do |format|
      if @payment.update_attributes(params[:payment])
        format.html { redirect_to @payment, notice: 'Payment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @payment = Payment.find(params[:id])
    @payment.destroy

    respond_to do |format|
      format.html { redirect_to payments_url }
      format.json { head :no_content }
    end
  end
end
