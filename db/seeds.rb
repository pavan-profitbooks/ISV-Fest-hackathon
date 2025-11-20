# Clear existing data
puts "Clearing existing data..."
Expense.destroy_all
Receipt.destroy_all
Rule.destroy_all
Category.destroy_all
Vendor.destroy_all
User.destroy_all

# Create users
puts "Creating users..."
user1 = User.create!(
  username: "john_doe",
  email: "john@example.com",
  password: "password123",
  password_confirmation: "password123"
)

user2 = User.create!(
  username: "jane_smith",
  email: "jane@example.com",
  password: "password123",
  password_confirmation: "password123"
)

puts "Created #{User.count} users"

# Create vendors for user1
puts "Creating vendors..."
vendor1 = user1.vendors.create!(
  name: "Amazon",
  email: "orders@amazon.com",
  address: "410 Terry Ave N, Seattle, WA 98109"
)

vendor2 = user1.vendors.create!(
  name: "Starbucks",
  email: "info@starbucks.com",
  address: "2401 Utah Ave S, Seattle, WA 98134"
)

vendor3 = user1.vendors.create!(
  name: "Office Depot",
  email: "support@officedepot.com",
  address: "6600 N Military Trail, Boca Raton, FL 33496"
)

vendor4 = user1.vendors.create!(
  name: "Shell Gas Station",
  email: "contact@shell.com",
  address: "123 Main St, Anytown, USA"
)

puts "Created #{Vendor.count} vendors"

# Create categories for user1
puts "Creating categories..."
cat_office = user1.categories.create!(
  name: "Office Supplies",
  description: "Supplies for office use"
)

cat_food = user1.categories.create!(
  name: "Food & Beverage",
  description: "Meals and drinks"
)

cat_travel = user1.categories.create!(
  name: "Travel",
  description: "Transportation and fuel"
)

cat_tech = user1.categories.create!(
  name: "Technology",
  description: "Tech equipment and software"
)

cat_uncategorized = user1.categories.create!(
  name: "Uncategorized",
  description: "Uncategorized expenses"
)

puts "Created #{Category.count} categories"

# Create rules for user1
puts "Creating rules..."
user1.rules.create!(
  pattern: "starbucks",
  category: cat_food
)

user1.rules.create!(
  pattern: "office depot",
  category: cat_office
)

user1.rules.create!(
  pattern: "shell",
  category: cat_travel
)

user1.rules.create!(
  pattern: "amazon",
  category: cat_tech,
  amount_threshold: 100.00
)

puts "Created #{Rule.count} rules"

# Create receipts and expenses for user1
puts "Creating receipts and expenses..."
receipt1 = user1.receipts.create!(
  merchant: "Starbucks",
  amount: 15.50,
  date: Date.today - 2.days,
  notes: "Morning coffee meeting",
  vendor: vendor2
)

receipt2 = user1.receipts.create!(
  merchant: "Office Depot",
  amount: 89.99,
  date: Date.today - 5.days,
  notes: "Printer paper and pens",
  vendor: vendor3
)

receipt3 = user1.receipts.create!(
  merchant: "Shell Gas Station",
  amount: 45.00,
  date: Date.today - 1.day,
  notes: "Fuel for business trip",
  vendor: vendor4
)

receipt4 = user1.receipts.create!(
  merchant: "Amazon",
  amount: 250.00,
  date: Date.today - 7.days,
  notes: "Laptop accessories",
  vendor: vendor1
)

receipt5 = user1.receipts.create!(
  merchant: "Starbucks",
  amount: 8.75,
  date: Date.today,
  notes: "Afternoon coffee",
  vendor: vendor2
)

puts "Created #{Receipt.count} receipts"
puts "Created #{Expense.count} expenses (auto-generated from receipts)"

# Update some expense statuses
puts "Updating expense statuses..."
Expense.first.update(status: :approved)
Expense.second.update(status: :approved)
Expense.last.update(status: :rejected)

puts "\n✅ Seed data created successfully!"
puts "\nLogin credentials:"
puts "Email: john@example.com"
puts "Password: password123"
puts "\nOr"
puts "Email: jane@example.com"
puts "Password: password123"
