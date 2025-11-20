class Receipt < ApplicationRecord
  belongs_to :vendor
  belongs_to :user
  has_one :expense, dependent: :destroy
  has_one_attached :image
  
  validates :merchant, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
  
  after_create :generate_expense
  
  private
  
  def generate_expense
    category = determine_category
    Expense.create!(
      amount: amount,
      date: date,
      description: "Expense from receipt #{merchant} - #{date}",
      category: category || user.categories.find_or_create_by!(name: 'Uncategorized'),
      receipt: self,
      vendor: vendor,
      user: user,
      status: :pending
    )
  end
  
  def determine_category
    user.rules.includes(:category).find do |rule|
      merchant.downcase.match?(rule.pattern.downcase) ||
        (rule.amount_threshold && amount >= rule.amount_threshold)
    end&.category
  end
end
