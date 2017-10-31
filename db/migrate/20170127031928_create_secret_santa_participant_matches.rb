# frozen_string_literal: true

class CreateSecretSantaParticipantMatches < ActiveRecord::Migration[4.2]
  def change
    create_table :secret_santa_participant_matches do |t|
      t.integer :match_id
      t.integer :secret_santa_participant_id
      t.boolean :test

      t.timestamps null: false
    end
  end
end
