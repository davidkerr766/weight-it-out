class LineItemsController < ApplicationController
    before_action :current_order

    def create
        chosen_product = Product.find(params[:product_id])
        # If cart already has this product then find the relevant line_item and iterate quantity otherwise create a new line_item for this product
        if @current_order.products.include?(chosen_product)
          @line_item = @current_order.line_items.find_by(:product_id => chosen_product)
          @line_item.quantity += 1
        else
          @line_item = LineItem.new
          @line_item.order_id = @current_order.id
          @line_item.product = chosen_product
        end
      
        # Save and redirect to cart show path
        @line_item.save
        redirect_to order_path(@current_order)
      end
      
      private
        def line_item_params
          params.require(:line_item).permit(:quantity,:product_id, :cart_id)
        end

        def current_order
            if current_user.orders.where(paid: false) == []
                @current_order = Order.create(user_id: current_user.id)
            else
                @current_order = current_user.orders.last
            end
        end
end
