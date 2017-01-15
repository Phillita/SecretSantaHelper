class AddPassphraseToSecretSanta < ActiveRecord::Migration
  def change
    add_column :secret_santas, :passphrase, :string, after: :last_run_on
  end
end
