class AddGuestToUsers < ActiveRecord::Migration
  def change
    add_column :users, :guest, :datetime
  end
end
