class Expense < ApplicationRecord
  belongs_to :category
  belongs_to :receipt
  belongs_to :vendor
  belongs_to :user
  
  enum :status, { pending: 0, approved: 1, rejected: 2 }
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
  
  scope :by_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :by_status, ->(status) { where(status: status) }
  scope :recent, -> { order(date: :desc) }
end
