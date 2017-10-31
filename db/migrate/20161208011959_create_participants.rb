# frozen_string_literal: true

class CreateParticipants < ActiveRecord::Migration[4.2]
  def change
    create_table :participants do |t|
      t.string :participantable_type
      t.integer :participantable_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
