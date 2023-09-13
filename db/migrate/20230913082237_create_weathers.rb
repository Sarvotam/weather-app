class CreateWeathers < ActiveRecord::Migration[6.1]
  def change
    create_table :weathers do |t|
        t.string :lat
        t.string :lon
        t.string :weather
        t.string :description
        t.integer :pressure
        t.integer :humidity
        t.string :country
        t.string :name
        t.datetime :created_at
        t.datetime :updated_at
    end
  end
end
