class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    # Summary statistics for the dashboard
    @total_expenses = current_user.expenses.sum(:amount)
    @monthly_expenses = current_user.expenses.where(date: Date.today.beginning_of_month..Date.today.end_of_month).sum(:amount)
    @pending_count = current_user.expenses.pending.count
    @categories_count = current_user.categories.count
  end

  # Expense Reports
  def expenses_by_date
    @start_date = params[:start_date]&.to_date || Date.today.beginning_of_month
    @end_date = params[:end_date]&.to_date || Date.today.end_of_month
    @period = params[:period] || 'monthly'

    @expenses = current_user.expenses
      .where(date: @start_date..@end_date)
      .includes(:category, :vendor)
      .order(date: :desc)

    @total = @expenses.sum(:amount)
    @count = @expenses.count
    @average = @count > 0 ? @total / @count : 0
  end

  def expenses_by_category
    @start_date = params[:start_date]&.to_date || Date.today.beginning_of_month
    @end_date = params[:end_date]&.to_date || Date.today.end_of_month

    @expenses = current_user.expenses.where(date: @start_date..@end_date)
    @category_breakdown = @expenses.joins(:category).group('categories.name').sum(:amount)
    @total = @category_breakdown.values.sum
  end

  def expenses_by_vendor
    @start_date = params[:start_date]&.to_date || Date.today.beginning_of_month
    @end_date = params[:end_date]&.to_date || Date.today.end_of_month

    @expenses = current_user.expenses.where(date: @start_date..@end_date)
    @vendor_breakdown = @expenses.joins(:vendor).group('vendors.name').sum(:amount).sort_by { |_, amount| -amount }
    @total = @vendor_breakdown.sum { |_, amount| amount }
  end

  def expenses_by_status
    @start_date = params[:start_date]&.to_date || Date.today.beginning_of_month
    @end_date = params[:end_date]&.to_date || Date.today.end_of_month

    @expenses = current_user.expenses.where(date: @start_date..@end_date)

    @status_breakdown = {
      pending: @expenses.pending.sum(:amount),
      approved: @expenses.approved.sum(:amount),
      rejected: @expenses.rejected.sum(:amount)
    }

    @status_counts = {
      pending: @expenses.pending.count,
      approved: @expenses.approved.count,
      rejected: @expenses.rejected.count
    }

    @total = @status_breakdown.values.sum
  end

  # Vendor Reports
  def top_vendors
    @limit = params[:limit]&.to_i || 10
    @start_date = params[:start_date]&.to_date || Date.today.beginning_of_year
    @end_date = params[:end_date]&.to_date || Date.today.end_of_year

    @top_vendors = current_user.expenses
      .where(date: @start_date..@end_date)
      .joins(:vendor)
      .group('vendors.id', 'vendors.name')
      .select('vendors.id, vendors.name, SUM(expenses.amount) as total_amount, COUNT(expenses.id) as transaction_count')
      .order('total_amount DESC')
      .limit(@limit)
  end

  def vendor_transactions
    @vendor_id = params[:vendor_id]
    @start_date = params[:start_date]&.to_date || Date.today.beginning_of_year
    @end_date = params[:end_date]&.to_date || Date.today.end_of_year

    if @vendor_id.present?
      @vendor = current_user.vendors.find(@vendor_id)
      @expenses = @vendor.expenses
        .where(date: @start_date..@end_date)
        .includes(:category, :receipt)
        .order(date: :desc)
      @total = @expenses.sum(:amount)
    end

    @vendors = current_user.vendors.order(:name)
  end

  # Category Reports
  def category_trends
    @months = params[:months]&.to_i || 6
    @end_date = Date.today
    @start_date = @end_date - @months.months

    @categories = current_user.categories.order(:name)
    @category_data = {}

    @categories.each do |category|
      expenses = category.expenses.where(date: @start_date..@end_date)
      # Group by month manually
      monthly_data = {}
      expenses.each do |expense|
        month_key = expense.date.beginning_of_month
        monthly_data[month_key] ||= 0
        monthly_data[month_key] += expense.amount
      end
      @category_data[category.name] = monthly_data.sort.to_h
    end
  end

  def category_summary
    @start_date = params[:start_date]&.to_date || Date.today.beginning_of_month
    @end_date = params[:end_date]&.to_date || Date.today.end_of_month

    @categories = current_user.categories.order(:name)
    @category_stats = @categories.map do |category|
      expenses = category.expenses.where(date: @start_date..@end_date)
      {
        category: category,
        total: expenses.sum(:amount),
        count: expenses.count,
        average: expenses.count > 0 ? expenses.sum(:amount) / expenses.count : 0,
        pending: expenses.pending.sum(:amount),
        approved: expenses.approved.sum(:amount)
      }
    end
  end

  # Receipt Reports
  def unprocessed_receipts
    # Get all receipts that don't have an associated expense
    all_receipts = current_user.receipts.includes(:expenses).order(date: :desc)
    @receipts = all_receipts.select { |receipt| receipt.expenses.empty? }

    @total_amount = @receipts.sum(&:amount)
  end

  def receipts_by_date
    @start_date = params[:start_date]&.to_date || Date.today.beginning_of_month
    @end_date = params[:end_date]&.to_date || Date.today.end_of_month

    @receipts = current_user.receipts
      .where(date: @start_date..@end_date)
      .includes(:vendor, :expenses)
      .order(date: :desc)

    @total = @receipts.sum(:amount)
    @processed = @receipts.joins(:expenses).distinct.count
    @unprocessed = @receipts.count - @processed
  end

  # Summary/Analytics Reports
  def monthly_trends
    @months = params[:months]&.to_i || 12
    @end_date = Date.today.end_of_month
    @start_date = (@end_date - @months.months).beginning_of_month

    expenses = current_user.expenses.where(date: @start_date..@end_date)

    # Group by month manually
    @monthly_data = {}
    @monthly_counts = {}

    expenses.each do |expense|
      month_key = expense.date.beginning_of_month
      @monthly_data[month_key] ||= 0
      @monthly_data[month_key] += expense.amount
      @monthly_counts[month_key] ||= 0
      @monthly_counts[month_key] += 1
    end

    @monthly_data = @monthly_data.sort.to_h
    @monthly_counts = @monthly_counts.sort.to_h
  end

  def year_comparison
    @current_year = params[:year]&.to_i || Date.today.year
    @previous_year = @current_year - 1

    # Get expenses for both years
    current_expenses = current_user.expenses
      .where(date: Date.new(@current_year, 1, 1)..Date.new(@current_year, 12, 31))

    previous_expenses = current_user.expenses
      .where(date: Date.new(@previous_year, 1, 1)..Date.new(@previous_year, 12, 31))

    # Group by month manually
    @current_year_data = {}
    current_expenses.each do |expense|
      month_key = expense.date.beginning_of_month
      @current_year_data[month_key] ||= 0
      @current_year_data[month_key] += expense.amount
    end

    @previous_year_data = {}
    previous_expenses.each do |expense|
      month_key = expense.date.beginning_of_month
      @previous_year_data[month_key] ||= 0
      @previous_year_data[month_key] += expense.amount
    end

    @current_year_data = @current_year_data.sort.to_h
    @previous_year_data = @previous_year_data.sort.to_h

    @current_total = @current_year_data.values.sum
    @previous_total = @previous_year_data.values.sum
    @change_percentage = @previous_total > 0 ? ((@current_total - @previous_total) / @previous_total * 100).round(2) : 0
  end

  def expense_summary
    @start_date = params[:start_date]&.to_date || Date.today.beginning_of_year
    @end_date = params[:end_date]&.to_date || Date.today.end_of_year

    @expenses = current_user.expenses.where(date: @start_date..@end_date)

    @summary = {
      total: @expenses.sum(:amount),
      count: @expenses.count,
      average: @expenses.average(:amount) || 0,
      highest: @expenses.maximum(:amount) || 0,
      lowest: @expenses.minimum(:amount) || 0,
      pending: @expenses.pending.sum(:amount),
      approved: @expenses.approved.sum(:amount),
      rejected: @expenses.rejected.sum(:amount)
    }

    @top_categories = @expenses.joins(:category)
      .group('categories.name')
      .sum(:amount)
      .sort_by { |_, amount| -amount }
      .first(5)

    @top_vendors = @expenses.joins(:vendor)
      .group('vendors.name')
      .sum(:amount)
      .sort_by { |_, amount| -amount }
      .first(5)
  end
end
