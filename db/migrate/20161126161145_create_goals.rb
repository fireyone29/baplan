class CreateGoals < ActiveRecord::Migration[5.0]
  def change
    create_table :goals do |t|
      t.belongs_to :user, :null => false

      t.string :description, :null => false
      t.index [:description, :user_id], :unique => true

      t.integer :frequency, default: 0

      t.timestamps
    end
  end
end
