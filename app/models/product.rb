class Product < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_by_product_name, against: :product_name

  belongs_to :category
  belongs_to :user

  has_many :line_items, dependent: :destroy
  has_many :orders, through: :line_items

  has_one_attached :picture

  validates :product_name, presence: true, format: { without: /\W/, message: "only allows letters and numbers" }, length: { maximum: 50 }
  validates :description, presence: true, format: { without: /\W/, message: "only allows letters and numbers" }, length: { maximum: 200 }
  validates :price, presence: true, numericality: { greater_than: 4.99}
  validates :quantity, presence: true, numericality: { only_integer: true , greater_than: 0}
  validates :picture, presence: true, blob: { content_type: ['image/png', 'image/jpg', 'image/jpeg'], size_range: 0..2.megabytes }

  
  def total_rented
    count = 0
    # An array of all the order_ids of orders that include the product and have been paid
    paid = self.orders.where(paid: true).map { |order|  order.id }
    # If the lineitem belongs to an order that has been paid the quantity is added to the total_rented count
    self.line_items.each { |line|
        count += line.quantity if paid.include? line.order_id
    }
    return count
  end

  def revenue
    self.total_rented * self.price
  end
end
