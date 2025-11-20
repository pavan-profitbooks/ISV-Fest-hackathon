class Rule < ApplicationRecord
  belongs_to :category
  belongs_to :user
  
  validates :pattern, presence: true
  validates :amount_threshold, numericality: { greater_than: 0 }, allow_nil: true
end
