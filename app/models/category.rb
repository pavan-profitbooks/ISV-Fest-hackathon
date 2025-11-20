class Category < ApplicationRecord
  belongs_to :user
  has_many :rules, dependent: :destroy
  has_many :expenses, dependent: :restrict_with_error
  
  validates :name, presence: true, uniqueness: { scope: :user_id }
  
  def to_s
    name
  end
end
