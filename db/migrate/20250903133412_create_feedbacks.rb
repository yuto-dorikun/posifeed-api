class CreateFeedbacks < ActiveRecord::Migration[7.2]
  def change
    create_table :feedbacks do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.references :organization, null: false, foreign_key: true
      
      t.integer :category, null: false
      t.text :message, null: false
      t.boolean :is_anonymous, default: false, null: false
      t.datetime :read_at
      t.integer :reactions_count, default: 0, null: false

      t.timestamps
    end

    # Performance indexes
    add_index :feedbacks, [:receiver_id, :created_at], order: { created_at: :desc }
    add_index :feedbacks, [:sender_id, :created_at], order: { created_at: :desc }
    add_index :feedbacks, [:organization_id, :created_at], order: { created_at: :desc }
    add_index :feedbacks, [:receiver_id, :read_at], where: "read_at IS NULL"

    # Data integrity constraints
    add_check_constraint :feedbacks, "sender_id != receiver_id", name: "no_self_feedback"
    add_check_constraint :feedbacks, "char_length(message) > 0 AND char_length(message) <= 1000", name: "message_length"
    add_check_constraint :feedbacks, "category IN (0, 1, 2, 3)", name: "valid_category"
  end
end
