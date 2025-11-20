class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  def index
    @categories = current_user.categories.order(:name)
    @category_expenses = current_user.expenses.group(:category_id).sum(:amount)
  end

  def show
    @expenses = @category.expenses.includes(:vendor, :receipt).order(date: :desc)
    @total_expenses = @expenses.sum(:amount)
  end

  def new
    @category = current_user.categories.build
  end

  def create
    @category = current_user.categories.build(category_params)

    if @category.save
      redirect_to categories_path, notice: 'Category was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: 'Category was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.expenses.any?
      redirect_to categories_path, alert: 'Cannot delete category with existing expenses. Please reassign or delete the expenses first.'
    else
      @category.destroy
      redirect_to categories_path, notice: 'Category was successfully deleted.'
    end
  end

  private

  def set_category
    @category = current_user.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :description)
  end
end
