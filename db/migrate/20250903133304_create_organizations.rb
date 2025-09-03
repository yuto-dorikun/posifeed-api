class CreateOrganizations < ActiveRecord::Migration[7.2]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.text :description
      t.string :domain
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :organizations, :domain, unique: true
    add_index :organizations, :active
  end
end
