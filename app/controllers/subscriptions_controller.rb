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

      current_user.assign_attributes(stripe_subscription_id: subscription.id, expires_at: nil)
      current_user.assign_attributes(
        card_brand: params[:user][:cardbrand],
        card_last4: params[:user][:cardlast4],
        card_exp_month: params[:user][:cardexp_month],
        card_exp_year: params[:user][:cardexp_year]
      ) if params[:user] && params[:user][:cardlast4]

      current_user.save

      flash.notice = "Thanks for subscribing!"
      redirect_to root_path
    rescue Stripe::CardError => e
      flash.alert = e.message
      render action: :new
    end
  end

  def show
  end

  def update
    customer = current_user.stripe_customer

    begin
      source = customer.sources.create(source: params[:stripeToken])

      customer.default_source = source.id
      customer.save

      current_user.assign_attributes(
        card_brand: params[:user][:cardbrand],
        card_last4: params[:user][:cardlast4],
        card_exp_month: params[:user][:cardexp_month],
        card_exp_year: params[:user][:cardexp_year]
      )

      current_user.save

      flash.notice = "Your card was updated successfully"
      redirect_to root_path
    rescue Stripe::CardError => e
      flash.alert = e.message
      render action: :show
    end
  end

  def destroy
    customer = current_user.stripe_customer
    subscription = customer.subscriptions.retrieve(current_user.stripe_subscription_id).delete

    expires_at = Time.zone.at(subscription.current_period_end)
    current_user.update(expires_at: expires_at, stripe_subscription_id: nil)

    redirect_to root_path, notice: "You have canceled your subscription. You will have access until #{current_user.expires_at.to_date}"
  end
end
