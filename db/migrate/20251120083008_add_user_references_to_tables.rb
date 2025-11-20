class AddUserReferencesToTables < ActiveRecord::Migration[8.0]
  def change
    add_reference :vendors, :user, null: false, foreign_key: true
  end
end
