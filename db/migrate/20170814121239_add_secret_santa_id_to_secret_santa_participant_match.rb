class AddSecretSantaIdToSecretSantaParticipantMatch < ActiveRecord::Migration
  def change
    add_column :secret_santa_participant_matches, :secret_santa_id, :integer, index: true, after: :id
  end
end
