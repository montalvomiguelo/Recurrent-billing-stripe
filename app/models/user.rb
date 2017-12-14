class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :charges

  def stripe_customer
    unless stripe_id?
      stripe_customer = Stripe::Customer.create(email: email)
      update(stripe_id: stripe_customer.id)
      return stripe_customer
    end

    Stripe::Customer.retrieve(stripe_id)
  end

  def subscribed?
    stripe_subscription_id? || (expires_at? && Time.zone.now < expires_at)
  end
end
