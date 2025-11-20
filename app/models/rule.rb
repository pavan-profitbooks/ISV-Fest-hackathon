class Rule < ApplicationRecord
  belongs_to :category
  belongs_to :user
end
