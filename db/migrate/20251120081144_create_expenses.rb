class CreateExpenses < ActiveRecord::Migration[8.0]
  def change
    create_table :expenses do |t|
      t.decimal :amount
      t.date :date
      t.text :description
      t.references :category, null: false, foreign_key: true
      t.references :receipt, null: false, foreign_key: true
      t.references :vendor, null: false, foreign_key: true
      t.integer :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
