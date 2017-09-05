# frozen_string_literal: false

class User < ApplicationRecord
  include ArelHelpers::ArelTable
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_PASSWORD_REGEX = /(?=.*\d)(?=.*[a-z])(?=.*[A-Z])/

  # Include default devise modules. Others available are:
  # :timeoutable, :omniauthable
  # Removed due to manual validation
  # :validatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :lockable, :confirmable, stretches: 12

  has_many :secret_santas, inverse_of: :user
  has_many :secret_santa_participants, inverse_of: :user

  before_save { self.email = email.downcase }

  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, length: { maximum: 50 }, allow_nil: true, allow_blank: true

  validates :email, presence: true,
                    length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX }
  validates :password, presence: true,
                       length: { minimum: 8 },
                       format: { with: VALID_PASSWORD_REGEX, message: 'Must have mixed case and at least one number.' },
                       if: :password_required?,
                       unless: :guest?
  validate :password_complexity, if: :password_required?, unless: :guest?
  validates_confirmation_of :password, if: :password_required?, unless: :guest?

  scope :guests, (-> { where.not(guest: nil) })

  def name
    "#{first_name} #{last_name}".strip
  end

  def guest?
    guest.present?
  end

  private

  def confirmation_required?
    !guest?
  end

  def password_complexity
    return unless (password.present? || encrypted_password.blank?) && !password.to_s.match(VALID_PASSWORD_REGEX)
    errors.add :password, 'must have mixed case and at least one number.'
  end

  def password_required?
    !persisted? || password.present? || password_confirmation.present?
  end
end
