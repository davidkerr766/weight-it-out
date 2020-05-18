class ApplicationController < ActionController::Base
    before_action :set_roles

    # User roles assigned to variables to reduce db queries
    def set_roles
        if user_signed_in?
            @admin = current_user.has_role? :admin
            @seller = current_user.has_role? :seller
        end
    end
end
