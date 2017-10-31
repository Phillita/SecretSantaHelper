# frozen_string_literal: true

class AddGuestToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :guest, :datetime
  end
end
