class CreateReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :reviews do |t|
      t.references :application, foreign_key: true
      t.text :content
      t.integer :rating
      t.string :title

      t.timestamps
    end
  end
end
