# frozen_string_literal: true

class CreateSecretSantas < ActiveRecord::Migration[4.2]
  def change
    create_table :secret_santas do |t|
      t.integer :user_id
      t.string :name
      t.boolean :send_file, default: false
      t.string :filename
      t.text :file_content
      t.boolean :send_email, default: true
      t.text :email_content
      t.string :email_subject
      t.datetime :test_run
      t.datetime :last_run_on

      t.timestamps null: false
    end
  end
end
