class AddAlsoRegToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :lectures, :also_reg, :string
  end
end
