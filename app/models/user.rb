# frozen_string_literal: false

class User < ActiveRecord::Base
  include ArelHelpers::ArelTable
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_PASSWORD_REGEX = /(?=.*\d)(?=.*[a-z])(?=.*[A-Z])/

  # Include default devise modules. Others available are:
  # :timeoutable, :omniauthable, :validatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :lockable, :confirmable, stretches: 12

  has_many :secret_santas

  before_save { self.email = email.downcase }

  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, length: { maximum: 50 }, allow_nil: true, allow_blank: true

  validates :email, presence: true,
                    length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX }
  validates :password, presence: true,
                       length: { minimum: 8 },
                       format: { with: VALID_PASSWORD_REGEX, message: 'Must have mixed case and at least one number.' },
                       if: 'password_confirmation.present?',
                       unless: :guest?
  validate :password_complexity

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
    return unless password.present? && !password.match(VALID_PASSWORD_REGEX)
    errors.add :password, 'must have mixed case and at least one number.'
  end
end
