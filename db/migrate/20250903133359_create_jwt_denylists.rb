class CreateJwtDenylists < ActiveRecord::Migration[7.2]
  def change
    create_table :jwt_denylists do |t|
      t.string :jti, null: false
      t.datetime :exp, null: false
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end

    add_index :jwt_denylists, :jti, unique: true
    add_index :jwt_denylists, :exp
  end
end
