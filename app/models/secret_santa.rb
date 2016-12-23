class SecretSanta < ActiveRecord::Base
  self.table_name = 'secret_santas'
  belongs_to :user, autosave: true
  alias_attribute :owner, :user
  has_many :secret_santa_participants, as: :participantable
  # has_many :matched_participants

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :secret_santa_participants, reject_if: :all_blank, allow_destroy: true

  before_create :default_email_and_file

  def autosave_associated_records_for_user
    # Find or create the author by name
    if user && new_user = User.find_by(email: user.email)
      self.user = new_user
    elsif user
      user.save!
      self.user = user
    end
  end

  # either the user said this is a test or has selected to not have a file or email sent
  # def test?
  #   test.present? || (!send_email? && !send_file?)
  # end

  private

  def default_email_and_file
    self.email_subject = '{{Giver}}: Find your SecretSanta Enclosed!'
    self.email_content = 'Hey {{Giver}}! Just in case you were wondering... Your Secret Santa for {{SecretSanta}} is: {{Receiver}}'
    self.filename = '{{Giver}}-secret-santa'
    self.file_content = 'Hey {{Giver}}! Just in case you were wondering... Your Secret Santa for {{SecretSanta}} is: {{Receiver}}'
  end
end
