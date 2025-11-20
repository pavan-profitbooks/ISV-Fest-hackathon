class CreateVendors < ActiveRecord::Migration[8.0]
  def change
    create_table :vendors do |t|
      t.string :name
      t.text :address
      t.string :phone
      t.string :email
      t.string :tax_identifier

      t.timestamps
    end
  end
end
