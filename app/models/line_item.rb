class LineItem < ApplicationRecord
  belongs_to :product
  belongs_to :order

  def total
    self.product.price * self.quantity
  end
end
