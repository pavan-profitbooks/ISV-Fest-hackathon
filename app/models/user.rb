class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :vendors, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :rules, dependent: :destroy
  has_many :receipts, dependent: :destroy
  has_many :expenses, dependent: :destroy

  # Validations
  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 50 }
  validates :email, presence: true, uniqueness: true

  def to_s
    username.presence || email
  end
  has_secure_password
  
  has_many :vendors, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :rules, dependent: :destroy
  has_many :receipts, dependent: :destroy
  has_many :expenses, dependent: :destroy
  
  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  
  def to_s
    username
  end
end
