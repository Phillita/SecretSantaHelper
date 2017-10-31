# frozen_string_literal: true

class AddPassphraseToSecretSanta < ActiveRecord::Migration[4.2]
  def change
    add_column :secret_santas, :passphrase, :string, after: :last_run_on
  end
end
