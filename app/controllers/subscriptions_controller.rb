class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def new

  end

  def create
    customer = current_user.stripe_customer

    begin
      subscription = customer.subscriptions.create(
        source: params[:stripeToken],
        plan: params[:plan]
      )

      current_user.assign_attributes(stripe_subscription_id: subscription.id)
      current_user.assign_attributes(
        card_brand: params[:user][:cardbrand],
        card_last4: params[:user][:cardlast4],
        card_exp_month: params[:user][:cardexp_month],
        card_exp_year: params[:user][:cardexp_year]
      ) if params[:user][:cardlast4]

      current_user.save

      flash.notice = "Thanks for subscribing!"
      redirect_to root_path
    rescue Stripe::CardError => e
      flash.alert = e.message
      render action: :new
    end
  end
end
