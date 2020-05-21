class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorise_user, except: [:index, :checkout, :show]
  before_action :set_order, only: [:show, :edit, :update, :destroy, :checkout]

  def index
    # If the request is from the "order history" link only paid orders are loaded from db
    # Only admin can see all orders otherwise a user can only see their orders
    if params[:show].present?
      @orders = current_user.orders.where(paid: true).order(updated_at: :desc)
    else
      # When an admin looks at all orders line items and their nested product and product's nested user are eager loaded
      @orders = (@admin ? Order.includes(line_items: [{product: :user}]).all : current_user.orders).order(updated_at: :desc)
    end

    # If a user has been redirected to orders index from stripe the query parameter must match the string saved in the session hash
    # to confirm a successful payment has been made and to prevent fraudulent query parameters provided by a malicious party
    # from validating a sale.
    if params[:key].present?
      if params[:key] == session[:key]
        cart = current_user.orders.last
        cart.paid = true
        cart.save
        # On successful payment the number of items are subtracted from the quantity of the relevant product
        cart.line_items.each { |line|
          product = line.product
          product.quantity -= line.quantity
          product.save 
        }
        flash[:notice] = "Payment Successful"
      else
        flash[:notice] = "Payment unsuccessful"
      end
      session.delete(:key)
    end
  end

  def show
  end

  def edit
  end

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
    # Random string generated and saved to session hash to later compare to query param and validate payment
    key = ('a'..'z').to_a.shuffle[0..7].join
    session[:key] = key
    Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)
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
    # Finds the order by the id sent through params
    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:paid)
    end

    def authorise_user
      redirect_to orders_path, notice: "User not authorised" if !@admin
    end
end
