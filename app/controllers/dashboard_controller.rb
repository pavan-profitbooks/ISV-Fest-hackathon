class DashboardController < ApplicationController
  def index
    @total_expenses = current_user.expenses.sum(:amount)
    @pending_expenses = current_user.expenses.pending.count
    @recent_receipts = current_user.receipts.order(date: :desc).limit(5)
    @expenses_by_category = current_user.expenses.joins(:category).group('categories.name').sum(:amount)
  rescue
    @total_expenses = 0
    @pending_expenses = 0
    @recent_receipts = []
    @expenses_by_category = {}
  end
end
