class ConvertUsersToDevise < ActiveRecord::Migration[8.0]
  def change
    # Add Devise fields
    change_table :users do |t|
      ## Database authenticatable
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable (optional - uncomment if you want to track sign-ins)
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip

      ## Confirmable (optional - uncomment if you want email confirmation)
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email

      ## Lockable (optional - uncomment if you want account locking)
      # t.string   :unlock_token
      # t.integer  :failed_attempts, default: 0, null: false
      # t.datetime :locked_at
    end

    # Add indexes
    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :username,             unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true

    # Remove old password_digest column (from has_secure_password)
    remove_column :users, :password_digest, :string

    # Make email non-nullable if it isn't already
    change_column_null :users, :email, false
    change_column_default :users, :email, from: nil, to: ""
  end
end
