class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :phone, :string
  end
end
