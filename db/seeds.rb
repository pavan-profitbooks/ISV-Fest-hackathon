# Clear existing data
puts "Clearing existing data..."
Expense.destroy_all
Receipt.destroy_all
Category.destroy_all
Vendor.destroy_all
Rule.destroy_all
User.destroy_all

# Create a test user
puts "Creating test user..."
user = User.create!(
  username: "testuser",
  email: "test@example.com",
  password: "password123",
  password_confirmation: "password123"
)

puts "User created: #{user.email}"

# Create categories
puts "Creating categories..."
categories = {
  food: Category.create!(name: "Food & Dining", description: "Restaurant, groceries, etc.", user: user),
  transport: Category.create!(name: "Transportation", description: "Gas, parking, public transit", user: user),
  utilities: Category.create!(name: "Utilities", description: "Electric, water, internet", user: user),
  entertainment: Category.create!(name: "Entertainment", description: "Movies, games, subscriptions", user: user),
  shopping: Category.create!(name: "Shopping", description: "Clothing, electronics, etc.", user: user),
  health: Category.create!(name: "Healthcare", description: "Medical, pharmacy, insurance", user: user),
  other: Category.create!(name: "Other", description: "Miscellaneous expenses", user: user)
}

puts "Created #{categories.count} categories"

# Create vendors
puts "Creating vendors..."
vendors = [
  Vendor.create!(name: "Starbucks", email: "contact@starbucks.com", phone: "555-0101", user: user),
  Vendor.create!(name: "Whole Foods", email: "info@wholefoods.com", phone: "555-0102", user: user),
  Vendor.create!(name: "Shell Gas Station", email: "support@shell.com", phone: "555-0103", user: user),
  Vendor.create!(name: "Netflix", email: "help@netflix.com", phone: "555-0104", user: user),
  Vendor.create!(name: "Amazon", email: "service@amazon.com", phone: "555-0105", user: user),
  Vendor.create!(name: "Walgreens", email: "contact@walgreens.com", phone: "555-0106", user: user),
  Vendor.create!(name: "Uber", email: "support@uber.com", phone: "555-0107", user: user),
  Vendor.create!(name: "Target", email: "help@target.com", phone: "555-0108", user: user)
]

puts "Created #{vendors.count} vendors"

# Create receipts and expenses
puts "Creating receipts and expenses..."

receipts_data = [
  { merchant: "Starbucks", amount: 15.50, date: 5.days.ago, vendor: vendors[0], category: categories[:food] },
  { merchant: "Whole Foods", amount: 125.75, date: 4.days.ago, vendor: vendors[1], category: categories[:food] },
  { merchant: "Shell Gas Station", amount: 45.00, date: 3.days.ago, vendor: vendors[2], category: categories[:transport] },
  { merchant: "Netflix", amount: 15.99, date: 2.days.ago, vendor: vendors[3], category: categories[:entertainment] },
  { merchant: "Amazon", amount: 89.99, date: 1.day.ago, vendor: vendors[4], category: categories[:shopping] },
  { merchant: "Walgreens", amount: 32.50, date: Date.today, vendor: vendors[5], category: categories[:health] },
  { merchant: "Uber", amount: 28.75, date: 6.days.ago, vendor: vendors[6], category: categories[:transport] },
  { merchant: "Target", amount: 67.80, date: 7.days.ago, vendor: vendors[7], category: categories[:shopping] },
  { merchant: "Starbucks", amount: 12.25, date: 8.days.ago, vendor: vendors[0], category: categories[:food] },
  { merchant: "Whole Foods", amount: 98.40, date: 10.days.ago, vendor: vendors[1], category: categories[:food] },
  { merchant: "Shell Gas Station", amount: 52.30, date: 12.days.ago, vendor: vendors[2], category: categories[:transport] },
  { merchant: "Amazon", amount: 145.20, date: 15.days.ago, vendor: vendors[4], category: categories[:shopping] },
  { merchant: "Uber", amount: 19.50, date: 18.days.ago, vendor: vendors[6], category: categories[:transport] },
  { merchant: "Target", amount: 54.75, date: 20.days.ago, vendor: vendors[7], category: categories[:other] },
  { merchant: "Walgreens", amount: 28.90, date: 25.days.ago, vendor: vendors[5], category: categories[:health] }
]

receipts_data.each do |data|
  receipt = Receipt.create!(
    merchant: data[:merchant],
    amount: data[:amount],
    date: data[:date],
    vendor: data[:vendor],
    user: user,
    notes: "Receipt for #{data[:merchant]}"
  )

  # Create expense for each receipt
  status = [:pending, :approved, :rejected].sample
  Expense.create!(
    amount: data[:amount],
    date: data[:date],
    description: "Purchase at #{data[:merchant]}",
    category: data[:category],
    vendor: data[:vendor],
    receipt: receipt,
    status: status,
    user: user
  )
end

puts "Created #{Receipt.count} receipts and #{Expense.count} expenses"

# Create some rules for auto-categorization
puts "Creating categorization rules..."
Rule.create!(pattern: "starbucks", category: categories[:food], user: user)
Rule.create!(pattern: "whole foods", category: categories[:food], user: user)
Rule.create!(pattern: "shell", category: categories[:transport], user: user)
Rule.create!(pattern: "netflix", category: categories[:entertainment], user: user)
Rule.create!(pattern: "amazon", category: categories[:shopping], user: user)
Rule.create!(pattern: "walgreens", category: categories[:health], user: user)
Rule.create!(pattern: "uber", category: categories[:transport], user: user)

puts "Created #{Rule.count} rules"

puts "\n" + "="*50
puts "Seed data created successfully!"
puts "="*50
puts "Login credentials:"
puts "  Email: test@example.com"
puts "  Password: password123"
puts "\nData summary:"
puts "  Users: #{User.count}"
puts "  Categories: #{Category.count}"
puts "  Vendors: #{Vendor.count}"
puts "  Receipts: #{Receipt.count}"
puts "  Expenses: #{Expense.count}"
puts "  Rules: #{Rule.count}"
puts "\nTotal expense amount: $#{Expense.sum(:amount).round(2)}"
puts "="*50
