class Order < ApplicationRecord
  belongs_to :user

  has_many :line_items, dependent: :destroy
  has_many :products, through: :line_items

  def order_total
    sum = 0
    self.line_items.each { |item|
      sum += item.total
    }
    return sum
  end
end
