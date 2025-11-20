class ExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_expense, only: [:show, :edit, :update, :destroy, :approve, :reject]

  def index
    @expenses = current_user.expenses.includes(:vendor, :category, :receipt).order(date: :desc)

    # Filter by status if provided
    @expenses = @expenses.where(status: params[:status]) if params[:status].present?

    # Filter by category if provided
    @expenses = @expenses.where(category_id: params[:category_id]) if params[:category_id].present?

    # Filter by date range if provided
    if params[:start_date].present? && params[:end_date].present?
      @expenses = @expenses.where(date: params[:start_date]..params[:end_date])
    end

    @categories = current_user.categories
    @total_expenses = @expenses.sum(:amount)
  end

  def show
  end

  def new
    @expense = current_user.expenses.build
    @vendors = current_user.vendors
    @categories = current_user.categories
    @receipts = current_user.receipts
  end

  def create
    @expense = current_user.expenses.build(expense_params)

    if @expense.save
      redirect_to @expense, notice: 'Expense was successfully created.'
    else
      @vendors = current_user.vendors
      @categories = current_user.categories
      @receipts = current_user.receipts
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @vendors = current_user.vendors
    @categories = current_user.categories
    @receipts = current_user.receipts
  end

  def update
    if @expense.update(expense_params)
      redirect_to @expense, notice: 'Expense was successfully updated.'
    else
      @vendors = current_user.vendors
      @categories = current_user.categories
      @receipts = current_user.receipts
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @expense.destroy
    redirect_to expenses_url, notice: 'Expense was successfully deleted.'
  end

  def approve
    @expense.update(status: 'approved')
    redirect_to @expense, notice: 'Expense was approved.'
  end

  def reject
    @expense.update(status: 'rejected')
    redirect_to @expense, notice: 'Expense was rejected.'
  end

  private

  def set_expense
    @expense = current_user.expenses.find(params[:id])
  end

  def expense_params
    params.require(:expense).permit(:amount, :date, :description, :status, :category_id, :vendor_id, :receipt_id)
  end
end
