### Execution Plan (3 Hours)

#### Hour 1: Project Setup & Models (60 mins)
```ruby
# Initialize Rails Project
rails new personal_expense_tracker -d mysql --css tailwind

# Generate Models
rails g model User email:string name:string
rails g model Vendor name:string address:text phone:string email:string tax_identifier:string
rails g model Category name:string description:text
rails g model Rule pattern:string category:references amount_threshold:decimal
rails g model Receipt merchant:string amount:decimal date:date image:string notes:text vendor:references
rails g model Expense amount:decimal date:date description:text category:references receipt:references vendor:references status:integer

# Model Definitions
# app/models/vendor.rb
class Vendor < ApplicationRecord
  has_many :receipts
  has_many :expenses
  
  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end

# app/models/receipt.rb
class Receipt < ApplicationRecord
  belongs_to :vendor
  has_one :expense
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
  
  after_create :generate_expense
  
  private
  
  def generate_expense
    category = determine_category
    Expense.create!(
      amount: amount,
      date: date,
      description: "Expense from receipt #{id}",
      category: category,
      receipt: self,
      vendor: vendor,
      status: :pending
    )
  end
  
  def determine_category
    Rule.all.find do |rule|
      merchant.downcase.match?(rule.pattern.downcase) ||
        (rule.amount_threshold && amount >= rule.amount_threshold)
    end&.category
  end
end

# app/models/expense.rb
class Expense < ApplicationRecord
  belongs_to :category
  belongs_to :receipt
  belongs_to :vendor
  
  enum status: { pending: 0, approved: 1, rejected: 2 }
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
  
  scope :by_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :by_status, ->(status) { where(status: status) }
end

# Database Setup
rails db:create
rails db:migrate

Copy

Insert at cursor
text
Hour 2: Controllers & Business Logic (60 mins)
# app/controllers/receipts_controller.rb
class ReceiptsController < ApplicationController
  def new
    @receipt = Receipt.new
    @vendors = Vendor.all
  end

  def create
    @receipt = Receipt.new(receipt_params)
    if @receipt.save
      redirect_to @receipt.expense, notice: 'Receipt processed and expense created.'
    else
      @vendors = Vendor.all
      render :new, status: :unprocessable_entity
    end
  end

  private
  
  def receipt_params
    params.require(:receipt).permit(:merchant, :amount, :date, :image, :notes, :vendor_id)
  end
end

# app/controllers/vendors_controller.rb
class VendorsController < ApplicationController
  def new
    @vendor = Vendor.new
  end

  def create
    @vendor = Vendor.new(vendor_params)
    if @vendor.save
      redirect_to new_receipt_path, notice: 'Vendor created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  
  def vendor_params
    params.require(:vendor).permit(:name, :address, :phone, :email, :tax_identifier)
  end
end

# app/controllers/expenses_controller.rb
class ExpensesController < ApplicationController
  def index
    @expenses = Expense.includes(:vendor, :category)
                      .order(date: :desc)
    @total = @expenses.sum(:amount)
    @expenses_by_category = @expenses.group(:category).sum(:amount)
  end

  def update
    @expense = Expense.find(params[:id])
    if @expense.update(expense_params)
      redirect_to expenses_path, notice: 'Expense updated successfully.'
    else
      redirect_to expenses_path, alert: 'Failed to update expense.'
    end
  end

  private
  
  def expense_params
    params.require(:expense).permit(:status)
  end
end

Copy

Insert at cursor
ruby
Hour 3: Views & Testing (60 mins)
# app/views/receipts/new.html.erb
<div class="max-w-2xl mx-auto p-4">
  <h1 class="text-2xl font-bold mb-4">New Receipt</h1>
  
  <%= form_with(model: @receipt, class: "space-y-4") do |f| %>
    <div>
      <%= f.label :vendor_id, class: "block text-sm font-medium" %>
      <%= f.collection_select :vendor_id, @vendors, :id, :name, 
          {prompt: "Select vendor"}, 
          class: "mt-1 block w-full rounded-md border-gray-300 shadow-sm" %>
      <%= link_to "Add New Vendor", new_vendor_path, 
          class: "text-blue-600 hover:text-blue-800 text-sm" %>
    </div>

    <div>
      <%= f.label :merchant, class: "block text-sm font-medium" %>
      <%= f.text_field :merchant, class: "mt-1 block w-full rounded-md border-gray-300 shadow-sm" %>
    </div>

    <div>
      <%= f.label :amount, class: "block text-sm font-medium" %>
      <%= f.number_field :amount, step: "0.01", class: "mt-1 block w-full rounded-md border-gray-300 shadow-sm" %>
    </div>

    <div>
      <%= f.label :date, class: "block text-sm font-medium" %>
      <%= f.date_field :date, class: "mt-1 block w-full rounded-md border-gray-300 shadow-sm" %>
    </div>

    <div>
      <%= f.label :image, class: "block text-sm font-medium" %>
      <%= f.file_field :image, class: "mt-1 block w-full" %>
    </div>

    <%= f.submit "Create Receipt", class: "w-full bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded" %>
  <% end %>
</div>

# Test Cases
# test/models/receipt_test.rb
require "test_helper"

class ReceiptTest < ActiveSupport::TestCase
  def setup
    @vendor = Vendor.create!(name: "Test Vendor")
    @category = Category.create!(name: "Office Supplies")
    @rule = Rule.create!(
      pattern: "staples",
      category: @category,
      amount_threshold: 100
    )
  end

  test "should not save receipt without required attributes" do
    receipt = Receipt.new
    assert_not receipt.save
    assert_includes receipt.errors[:amount], "can't be blank"
    assert_includes receipt.errors[:date], "can't be blank"
  end

  test "should create expense after receipt creation" do
    receipt = Receipt.create!(
      merchant: "Staples",
      amount: 150.00,
      date: Date.current,
      vendor: @vendor
    )
    
    assert receipt.expense.present?
    assert_equal @category, receipt.expense.category
    assert_equal "pending", receipt.expense.status
  end

  test "should match rule by merchant pattern" do
    receipt = Receipt.create!(
      merchant: "Staples Office Supply",
      amount: 50.00,
      date: Date.current,
      vendor: @vendor
    )
    
    assert_equal @category, receipt.expense.category
  end

  test "should match rule by amount threshold" do
    receipt = Receipt.create!(
      merchant: "Random Store",
      amount: 150.00,
      date: Date.current,
      vendor: @vendor
    )
    
    assert_equal @category, receipt.expense.category
  end
end

# test/models/vendor_test.rb
require "test_helper"

class VendorTest < ActiveSupport::TestCase
  test "should not save vendor without name" do
    vendor = Vendor.new
    assert_not vendor.save
    assert_includes vendor.errors[:name], "can't be blank"
  end

  test "should validate email format" do
    vendor = Vendor.new(name: "Test Vendor", email: "invalid-email")
    assert_not vendor.save
    assert_includes vendor.errors[:email], "is invalid"
    
    vendor.email = "valid@example.com"
    assert vendor.save
  end
end

# test/models/expense_test.rb
require "test_helper"

class ExpenseTest < ActiveSupport::TestCase
  def setup
    @vendor = Vendor.create!(name: "Test Vendor")
    @category = Category.create!(name: "Test Category")
    @receipt = Receipt.create!(
      merchant: "Test Merchant",
      amount: 100,
      date: Date.current,
      vendor: @vendor
    )
  end

  test "should create expense with valid attributes" do
    expense = Expense.new(
      amount: 100,
      date: Date.current,
      category: @category,
      receipt: @receipt,
      vendor: @vendor,
      status: :pending
    )
    assert expense.save
  end

  test "should not save expense without amount" do
    expense = Expense.new(
      date: Date.current,
      category: @category,
      receipt: @receipt,
      vendor: @vendor
    )
    assert_not expense.save
  end

  test "should have valid status" do
    expense = Expense.create!(
      amount: 100,
      date: Date.current,
      category: @category,
      receipt: @receipt,
      vendor: @vendor,
      status: :pending
    )
    
    assert expense.pending?
    expense.approved!
    assert expense.approved?
    expense.rejected!
    assert expense.rejected?
  end
end

Copy

Insert at cursor
ruby
Required Gems
# Gemfile
source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

gem "rails", "~> 7.1.0"
gem "sprockets-rails"
gem "mysql2", "~> 0.5"
gem "puma", "~> 6.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "jbuilder"
gem "redis", "~> 4.0"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false
gem "image_processing", "~> 1.2"

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "rspec-rails"
  gem "factory_bot_rails"
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

Copy

Insert at cursor
ruby
Next Steps (Post 3-hours)
Add user authentication with Devise

Implement advanced OCR for receipt scanning

Add expense approval workflow with notifications

Create API endpoints for mobile integration

Add reporting features with charts and exports

Implement multi-currency support

Add audit logging for expense changes

Create vendor performance analytics

Implement batch upload functionality

Add expense policy validation rules

This implementation provides a solid foundation for a receipt and expense tracking system with proper separation of concerns and automated testing. The focus is on maintainable, well-tested code while providing a good user experience.
MARKDOWN

File.write('implementation_plan.md', updated_content)

