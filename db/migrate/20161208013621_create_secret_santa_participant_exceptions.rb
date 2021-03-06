# frozen_string_literal: true

class CreateSecretSantaParticipantExceptions < ActiveRecord::Migration[4.2]
  def change
    create_table :secret_santa_participant_exceptions do |t|
      t.integer :exception_id
      t.integer :secret_santa_participant_id

      t.timestamps null: false
    end
  end
end
