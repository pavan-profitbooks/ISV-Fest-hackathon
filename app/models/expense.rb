class Expense < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :category, optional: true
  belongs_to :receipt, optional: true
  belongs_to :vendor, optional: true

  # Enums
  enum :status, { pending: 0, approved: 1, rejected: 2 }, default: :pending

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
  validates :status, presence: true

  # Scopes
  scope :by_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :by_status, ->(status) { where(status: status) }
  scope :recent, -> { order(date: :desc) }
end
