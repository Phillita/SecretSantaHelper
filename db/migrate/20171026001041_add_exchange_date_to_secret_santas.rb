class AddExchangeDateToSecretSantas < ActiveRecord::Migration[5.1]
  def change
    add_column :secret_santas, :exchange_date, :datetime, before: :last_run_on
  end
end
