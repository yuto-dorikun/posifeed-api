class CreateDepartments < ActiveRecord::Migration[7.2]
  def change
    create_table :departments do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :parent, null: true, foreign_key: { to_table: :departments }
      t.string :name, null: false
      t.text :description
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :departments, [:organization_id, :name], unique: true
    add_index :departments, :active
  end
end
