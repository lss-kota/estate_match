class CreateProperties < ActiveRecord::Migration[8.0]
  def change
    create_table :properties do |t|
      t.string :title
      t.text :description
      t.integer :sale_price
      t.integer :rental_price
      t.integer :deposit
      t.integer :key_money
      t.integer :management_fee
      t.string :prefecture
      t.string :city
      t.string :address
      t.string :nearest_station
      t.integer :station_distance
      t.integer :property_type
      t.decimal :building_area
      t.decimal :land_area
      t.string :rooms
      t.integer :construction_year
      t.boolean :parking
      t.string :floor_plan_image
      t.integer :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
