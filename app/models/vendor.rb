class Vendor < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :receipts, dependent: :destroy
  has_many :expenses, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
end
