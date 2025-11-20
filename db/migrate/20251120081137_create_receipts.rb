class CreateReceipts < ActiveRecord::Migration[8.0]
  def change
    create_table :receipts do |t|
      t.string :merchant
      t.decimal :amount
      t.date :date
      t.string :image
      t.text :notes
      t.references :vendor, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
