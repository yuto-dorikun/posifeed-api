class CreateFeedbackReactions < ActiveRecord::Migration[7.2]
  def change
    create_table :feedback_reactions do |t|
      t.references :feedback, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :reaction_type, null: false

      t.timestamps
    end

    add_index :feedback_reactions, [:feedback_id, :user_id], unique: true
    add_index :feedback_reactions, :reaction_type
  end
end
