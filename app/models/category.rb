class Category < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :expenses, dependent: :nullify
  has_many :rules, dependent: :destroy

  # Validations
  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :user, presence: true
end
