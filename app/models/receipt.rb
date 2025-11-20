class Receipt < ApplicationRecord
  belongs_to :vendor
  belongs_to :user
  has_many :expenses, dependent: :nullify

  validates :merchant, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
end
