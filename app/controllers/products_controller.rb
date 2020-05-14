class ProductsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :authorise_user, except: [:index, :show]
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :set_categories, only: [:new, :edit]
  before_action :owns_product, only: [:edit, :update, :destroy]

  def index
    if params[:show].present?
      puts "It worked"
      case params[:show]
      when "my_products"
        @products = Product.where(user_id: current_user.id)
      when "cardio"
        @category = Category.find_by name: "Cardio"
        set_products
      when "machines"
        @category = Category.find_by name: "Machines"
        set_products
      when "free"
        @category = Category.find_by name: "Free Weights"
        set_products
      end
    else
      @products = Product.all
    end
  end

  def sales
    @products = Product.where(user_id: current_user.id)
    @revenue = 0
    @products.each { |product|
        @revenue += product.total_rented * product.price
    }
  end

  def show
  end

  def new
    @product = Product.new
  end

  def edit
  end

  def create
    @product = Product.new(product_params)
    @product.user_id = current_user.id

    if @product.save
      # Assign the role seller if it is the first time a user has listed a product
      current_user.add_role :seller if !current_user.has_role? :seller
      redirect_to @product, notice: 'Product was successfully created.'
    else
      render :new
    end
  end

  def update
    if @product.update(product_params)
      redirect_to @product, notice: 'Product was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to products_url, notice: 'Product was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    def set_products
      @products = Product.where(category_id: @category.id)
    end

    def set_categories
      @categories = Category.all
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(:product_name, :description, :price, :quantity, :category_id)
    end

    def authorise_user
      redirect_to products_path, notice: "User not authorised" if !(current_user.has_role? :admin or current_user.has_role? :seller)
    end

    def owns_product
      if !(current_user.products.include? @product or current_user.has_role? :admin)
        redirect_to products_path, notice: "User not authorised"
      end
    end
end
