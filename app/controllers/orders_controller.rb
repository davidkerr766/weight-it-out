class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :edit, :update, :destroy, :checkout]

  def index
    if params[:show].present?
      @orders = current_user.orders.where(paid: true)
    else
      @orders = (current_user.has_role? :admin) ? Order.all : current_user.orders
    end

    if params[:key].present?
      if params[:key] == session[:key]
        cart = current_user.orders.last
        cart.paid = true
        cart.save
        cart.line_items.each { |line|
          product = line.product
          product.quantity -= line.quantity
          product.save 
        }
        flash[:notice] = "Payment Successful"
      end
      session.delete(:key)
    end
  end

  def show
  end

  # GET /orders/1/edit
  def edit
  end

  def create
    @order = Order.new(order_params)
    @order.user_id = current_user.id

    if @order.save
      redirect_to @order, notice: 'Order was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    if @order.update(order_params)
      redirect_to @order, notice: 'Order was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @order.destroy
    redirect_to orders_url, notice: 'Order was successfully destroyed.'
  end

  def checkout
    key = ('a'..'z').to_a.shuffle[0..7].join
    session[:key] = key
    Stripe.api_key = "sk_test_kqxu11Y98Ngk3DYmWaDBZuvS000rTRt5dQ"
    @session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: @order.line_items.map { |item|
        {
          name: item.product.product_name,
          description: item.product.description,
          amount: item.product.price.to_i * 100,
          currency: 'aud',
          quantity: item.quantity
        }
      },
      success_url: orders_url(:key => "#{key}"),
      cancel_url: order_url(@order),
    )
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def order_params
      params.require(:order).permit(:paid)
    end
end
