class MakeExpenseAssociationsOptional < ActiveRecord::Migration[8.0]
  def change
    change_column_null :expenses, :category_id, true
    change_column_null :expenses, :receipt_id, true
    change_column_null :expenses, :vendor_id, true
  end
end
