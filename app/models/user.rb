class User < ActiveRecord::Base
  include ArelHelpers::ArelTable
  # Include default devise modules. Others available are:
  # :timeoutable, :omniauthable, :validatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :lockable, :confirmable

  has_many :secret_santas

  before_save { self.email = email.downcase }

  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, length: { maximum: 50 }, allow_nil: true, allow_blank: true

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX }
  validates :email, uniqueness: { case_sensitive: false }, unless: :guest?

  validates :password, presence: true, length: { minimum: 6 }, unless: :guest?

  scope :guests, -> { where.not(guest: nil) }

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
end
