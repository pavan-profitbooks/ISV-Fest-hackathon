class Vendor < ApplicationRecord
  belongs_to :user
  has_many :receipts, dependent: :destroy
  has_many :expenses, dependent: :destroy
  
  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  
  def to_s
    name
  end
end
