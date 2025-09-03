# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :department, null: true, foreign_key: true
      
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Profile information
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :display_name
      t.string :job_title
      t.integer :role, default: 0, null: false
      t.boolean :active, default: true, null: false
      
      ## Counter cache
      t.integer :sent_feedbacks_count, default: 0, null: false
      t.integer :received_feedbacks_count, default: 0, null: false

      t.timestamps null: false
    end

    add_index :users, [:organization_id, :email], unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, [:organization_id, :active]
  end
end
