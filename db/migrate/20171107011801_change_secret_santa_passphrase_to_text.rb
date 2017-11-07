class ChangeSecretSantaPassphraseToText < ActiveRecord::Migration[5.1]
  def change
    change_column :secret_santas, :passphrase, :text
  end
end
