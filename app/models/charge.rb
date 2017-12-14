class Charge < ApplicationRecord
  belongs_to :user

  def receipt
    Receipts::Receipt.new(
      id: id,
      product: "Store",
      company: {
        name: "Example Co.",
        address: "123 Example Street",
        email: "support@example.com"
      },
      line_items: [
        ["Date", created_at.to_s],
        ["Account Billed", user.email],
        ["Product", "Store subscription"],
        ["Amount", ActionController::Base.helpers.number_to_currency(amount / 100)],
        ["Card Charged", "#{card_brand} (**** **** **** #{card_last4})"]
      ]
    )
  end
end
