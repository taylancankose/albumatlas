class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :username
      t.string :email
      t.json :address
      t.string :phone

      t.timestamps
    end
  end
end
