class CreateTutorials < ActiveRecord::Migration[5.1]
  def change
    create_table :tutorials do |t|
      t.string :name
      t.string :section
      t.string :term
      t.string :days
      t.string :s_time
      t.string :e_time
      t.string :location

      t.timestamps
    end
  end
end
