class Product < ApplicationRecord
  belongs_to :category
  belongs_to :user

  has_many :line_items, dependent: :destroy
  has_many :orders, through: :line_items

  has_one_attached :picture

  def total_rented
    count = 0
    paid = self.orders.where(paid: true).map { |order|  order.id }
    self.line_items.each { |line|
        count += line.quantity if paid.include? line.order_id
    }
    return count
  end
end
