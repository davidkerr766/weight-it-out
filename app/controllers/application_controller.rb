class ApplicationController < ActionController::Base
    before_action :set_nav_variables

    # Variables assigned for all the queries required in the nav bar
    def set_nav_variables
        if user_signed_in?
            @admin = current_user.has_role? :admin
            @seller = current_user.has_role? :seller
            # An array of all the orders of the current user.  The last order in the array will be the cart if paid == false
            @cart = current_user.orders
            # An array of line items in the cart
            @cart_items = @cart[-1].line_items.length if @cart[0] != nil && @cart[-1].paid == false
        end
    end
end
