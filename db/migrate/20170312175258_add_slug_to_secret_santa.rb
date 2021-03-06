# frozen_string_literal: true

class AddSlugToSecretSanta < ActiveRecord::Migration[4.2]
  def up
    add_column :secret_santas, :slug, :string, after: :name
    add_index :secret_santas, :slug, unique: true
    SecretSanta.reset_column_information
    SecretSanta.find_each(&:save)
  end

  def down
    remove_index :secret_santas, :slug
    remove_column :secret_santas, :slug
  end
end
