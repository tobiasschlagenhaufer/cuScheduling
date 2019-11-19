class AddStatusToLectures < ActiveRecord::Migration[5.1]
  def change
    add_column :lectures, :status, :string
  end
end
