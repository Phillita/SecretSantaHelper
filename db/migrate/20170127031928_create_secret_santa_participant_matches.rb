class CreateSecretSantaParticipantMatches < ActiveRecord::Migration
  def change
    create_table :secret_santa_participant_matches do |t|
      t.integer :match_id
      t.integer :secret_santa_participant_id
      t.boolean :test

      t.timestamps null: false
    end
  end
end