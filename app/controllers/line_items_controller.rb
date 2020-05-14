class LineItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :current_order
  before_action :set_line_item, only: [:add, :subtract, :destroy]
  before_action :owns_line_item, only: [:add, :subtract, :destroy]

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
        @line_item = LineItem.find(params[:id])
        if @line_item.quantity > 1
          @line_item.quantity -= 1
          @line_item.save
        else
          flash[:notice] = "Minimun of 1 item.  Selection can be removed from cart."
        end
        redirect_to order_path(@current_order)
      end

      def destroy
        @line_item = LineItem.find(params[:id])
        @line_item.destroy
        redirect_to order_path(@current_order)
      end
      
      private
        def set_line_item
          @line_item = LineItem.find(params[:id])
        end

        def current_order
            if current_user.orders.where(paid: false) == []
                @current_order = Order.create(user_id: current_user.id)
            else
                @current_order = current_user.orders.last
            end
        end

        # Redirects user if they try to edit a line_item they don't own
        def owns_line_item
          if !(current_user.line_items.include? @line_item or current_user.has_role? :admin)
            redirect_to products_path, notice: "User not authorised"
          end
        end
end
