class CreatePhotos < ActiveRecord::Migration[7.1]
  def change
    create_table :photos do |t|
      t.references :album, null: false, foreign_key: true
      t.string :title
      t.string :url
      t.string :thumbnail_url

      t.timestamps
    end
  end
end
