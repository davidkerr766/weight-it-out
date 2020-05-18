class Product < ApplicationRecord
  belongs_to :category
  belongs_to :user

  has_many :line_items, dependent: :destroy
  has_many :orders, through: :line_items

  has_one_attached :picture

  validates :product_name, presence: true, format: { with: /[\w ]/, message: "only allows letters and numbers" }, length: { maximum: 50 }
  validates :description, presence: true, format: { with: /[\w ]/, message: "only allows letters and numbers" }, length: { maximum: 200 }
  validates :price, presence: true, numericality: { greater_than: 4.99}
  validates :quantity, presence: true, numericality: { only_integer: true , greater_than: 0}
  validates :picture, presence: true, blob: { content_type: ['image/png', 'image/jpg', 'image/jpeg'], size_range: 0..2.megabytes }

  def total_rented
    count = 0
    paid = self.orders.where(paid: true).map { |order|  order.id }
    self.line_items.each { |line|
        count += line.quantity if paid.include? line.order_id
    }
    return count
  end

  def revenue
    self.total_rented * self.price
  end
end
