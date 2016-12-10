class CreateStreaks < ActiveRecord::Migration[5.0]
  def change
    create_table :streaks do |t|
      t.string :type
      t.references :goal, foreign_key: true, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
    end
    add_index :streaks, :start_date
    add_index :streaks, :end_date

    add_foreign_key :goals, :users
  end
end
