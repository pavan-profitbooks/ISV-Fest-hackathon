class Expense < ApplicationRecord
  belongs_to :category
  belongs_to :receipt
  belongs_to :vendor
  belongs_to :user
end
