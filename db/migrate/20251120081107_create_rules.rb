class CreateRules < ActiveRecord::Migration[8.0]
  def change
    create_table :rules do |t|
      t.string :pattern
      t.references :category, null: false, foreign_key: true
      t.decimal :amount_threshold
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
