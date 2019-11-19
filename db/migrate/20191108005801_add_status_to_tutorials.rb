class AddStatusToTutorials < ActiveRecord::Migration[5.1]
  def change
    add_column :tutorials, :status, :string
  end
end
