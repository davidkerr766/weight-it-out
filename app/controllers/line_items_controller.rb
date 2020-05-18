class LineItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :current_order
  before_action :set_line_item, only: [:add, :subtract, :destroy]
  before_action :authorise_user, only: [:add, :subtract, :destroy]

  def create
    chosen_product = Product.find(params[:product_id])
    # If the lineitem already exists in the cart the quantity is increased otherwise a new lineitem is added to the cart
    if @current_order.products.include?(chosen_product)
      @line_item = @current_order.line_items.find_by(:product_id => chosen_product)
      @line_item.quantity += 1
    else
      @line_item = LineItem.new(order_id: @current_order.id, product_id: chosen_product.id)
    end
    
    @line_item.save
    redirect_to order_path(@current_order)
  end

  def add
    if @line_item.product.quantity > @line_item.quantity
      @line_item.quantity += 1
      @line_item.save
    else
      flash[:notice] = "There are only #{@line_item.quantity} available for hire."
    end
    redirect_to order_path(@current_order)
  end

  def subtract
    if @line_item.quantity > 1
      @line_item.quantity -= 1
      @line_item.save
    else
      flash[:notice] = "Minimun of 1 item.  Selection can be removed from cart."
    end
    redirect_to order_path(@current_order)
  end

  def destroy
    @line_item.destroy
    redirect_to order_path(@current_order)
  end
      
  private
    # Finds the lineitem by the id sent through params
    def set_line_item
      @line_item = LineItem.find(params[:id])
    end
        
    # If the user does not have a cart (an order where paid == false) then a new order object is created
    def current_order
      if current_user.orders.where(paid: false) == []
        @current_order = Order.create(user_id: current_user.id)
      else
      # An unpaid order(cart) will always have the highest order_id as a new order wont't be initialised until all are paid
        @current_order = current_user.orders.last
      end
    end

    # Redirects user if they try to edit a line_item they don't own
    def authorise_user
      if !(current_user.line_items.include? @line_item or @admin)
        redirect_to products_path, notice: "User not authorised"
      end
    end
end
