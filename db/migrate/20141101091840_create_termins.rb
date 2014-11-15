class CreateTermins < ActiveRecord::Migration
  def change
    create_table :termins do |t|
      t.string :input
      t.string :date
      t.string :time
      t.string :todo
      t.string :formated_string
      t.string :finished
      t.timestamps
    end
  end
end
