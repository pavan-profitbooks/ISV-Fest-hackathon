# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal Expense Tracker - A Rails 8 application for managing receipts, expenses, and vendors with automated expense categorization. Built for the ISV-Fest hackathon.

**Tech Stack:**
- Rails 8.0.4
- Ruby 3.2.2
- SQLite3
- Devise for authentication
- Hotwire (Turbo + Stimulus)
- Solid Queue, Solid Cache, Solid Cable (database-backed adapters)

## Development Commands

### Setup
```bash
bin/setup                    # Initial setup: install dependencies, setup database
bundle install               # Install gem dependencies
bin/rails db:create         # Create databases
bin/rails db:migrate        # Run migrations
bin/rails db:seed           # Seed database with initial data
```

### Running the Application
```bash
bin/dev                     # Start development server (uses Procfile.dev)
bin/rails server            # Alternative: start Rails server only
```

### Database
```bash
bin/rails db:migrate        # Run pending migrations
bin/rails db:rollback       # Rollback last migration
bin/rails db:reset          # Drop, create, migrate, and seed database
bin/rails db:schema:load    # Load schema without running migrations
```

### Testing
```bash
bin/rails test              # Run all tests
bin/rails test test/models/user_test.rb          # Run specific test file
bin/rails test test/models/user_test.rb:10       # Run specific test at line 10
```

### Code Quality
```bash
bin/rubocop                 # Run RuboCop linter (Rails Omakase style)
bin/rubocop -a              # Auto-correct offenses
bin/brakeman                # Run security vulnerability scanner
```

### Console & Debugging
```bash
bin/rails console           # Start Rails console
bin/rails dbconsole         # Start database console
```

## Architecture & Data Model

### Core Domain Workflow

The application follows a **Receipt → Expense** workflow:

1. **User** creates a **Vendor** (optional, can be done inline)
2. **User** uploads/creates a **Receipt** (associated with Vendor)
3. **Receipt** automatically generates an **Expense** via `after_create` callback
4. **Expense** is auto-categorized using **Rules** that match:
   - Merchant name patterns (regex)
   - Amount thresholds
5. **Expense** is created with "pending" status for user review/approval

### Data Model Relationships

```
User (Devise)
  ├─ has_many :vendors
  ├─ has_many :categories
  ├─ has_many :rules
  ├─ has_many :receipts
  └─ has_many :expenses

Vendor
  ├─ belongs_to :user (Note: Schema shows vendor without user_id - check if implemented)
  ├─ has_many :receipts
  └─ has_many :expenses

Category
  ├─ belongs_to :user
  ├─ has_many :rules
  └─ has_many :expenses

Rule (Auto-categorization logic)
  ├─ belongs_to :category
  ├─ belongs_to :user
  └─ pattern (string) - matches against receipt merchant name
  └─ amount_threshold (decimal) - matches if receipt amount >= threshold

Receipt
  ├─ belongs_to :vendor
  ├─ belongs_to :user
  ├─ has_one :expense
  └─ After create: generates expense via determine_category logic

Expense
  ├─ belongs_to :category
  ├─ belongs_to :receipt
  ├─ belongs_to :vendor
  ├─ belongs_to :user
  └─ status (enum: pending, approved, rejected)
```

### Key Implementation Details

**Auto-Categorization Logic** (planned in implementation_plan.md):
- Located in `Receipt` model's `after_create :generate_expense` callback
- `determine_category` method:
  1. Checks all Rules for the user
  2. Matches merchant name against rule patterns (case-insensitive)
  3. Checks if amount meets threshold if specified
  4. Returns first matching category
  5. Falls back to "Uncategorized" category if no match

**Expense Status Workflow**:
- `pending` - Auto-created from receipt, awaiting review
- `approved` - User-approved expense
- `rejected` - User-rejected expense

## Current Development Status

Based on git status, the project is in early stages:

**Completed:**
- ✅ Rails 8 setup with Devise
- ✅ Database schema with all core models
- ✅ Model files created (basic associations only)
- ✅ Pending Devise migration: `db/migrate/20251120090000_add_devise_to_users.rb`

**Not Yet Implemented:**
- ⚠️ Model validations, scopes, and business logic
- ⚠️ `after_create` callback for automatic expense generation
- ⚠️ Auto-categorization logic in Receipt model
- ⚠️ Controllers (only ApplicationController exists)
- ⚠️ Views
- ⚠️ Routes configuration
- ⚠️ Tests

**Important Notes:**
- Vendor model appears to be missing `user_id` relationship in schema (present in plan but not in actual schema)
- Devise integration is installed but migration not yet run
- Implementation should follow the detailed plan in `implementation_plan.md` and `Exec_plan.md`

## File Structure

```
app/
├── controllers/        # Only application_controller.rb exists
├── models/            # Basic model files with Devise + associations only
├── views/             # Devise views only
│   └── devise/
└── javascript/        # Hotwire Stimulus controllers

config/
├── database.yml       # SQLite configuration
├── routes.rb          # Minimal routes, needs expansion
└── initializers/
    └── devise.rb      # Devise configuration

db/
├── migrate/           # All core migrations + pending Devise migration
└── schema.rb          # Current database structure
```

## Rails 8 Specific Features

This project uses Rails 8's modern defaults:

- **Solid Queue**: Database-backed job processing (replaces Redis/Sidekiq)
- **Solid Cache**: Database-backed caching
- **Solid Cable**: Database-backed ActionCable
- **Propshaft**: Modern asset pipeline (not Sprockets)
- **Importmap**: JavaScript management without Node.js
- **Kamal**: Docker deployment configuration

## Working with Devise

Devise is configured but not fully integrated:

- Migration pending: `db/migrate/20251120090000_add_devise_to_users.rb`
- User model has basic Devise modules: `:database_authenticatable, :registerable, :recoverable, :rememberable, :validatable`
- Need to run migration and configure routes before authentication works

## Key Implementation Patterns

When implementing features, follow these patterns from the plans:

**Receipt Processing:**
```ruby
# app/models/receipt.rb
after_create :generate_expense

def determine_category
  user.rules.find do |rule|
    merchant.downcase.match?(rule.pattern.downcase) ||
      (rule.amount_threshold && amount >= rule.amount_threshold)
  end&.category
end
```

**Expense Scoping:**
```ruby
# app/models/expense.rb
scope :by_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
scope :by_status, ->(status) { where(status: status) }
scope :recent, -> { order(date: :desc) }
```

**Controller Scoping:**
All models should be scoped to `current_user`:
```ruby
current_user.receipts.new(receipt_params)
current_user.expenses.includes(:vendor, :category).order(date: :desc)
```
