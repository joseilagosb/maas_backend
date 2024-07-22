class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  has_many :service_hour_users, dependent: :destroy
  has_many :service_hours, through: :service_hour_users

  validates :name, presence: true, uniqueness: true

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :jwt_authenticatable, jwt_revocation_strategy: self
  devise :validatable, password_length: 6..64

  enum role: { user: 0, admin: 1 }
  enum color: { red: 0, green: 1, blue: 2, yellow: 3, orange: 4, purple: 5, pink: 6 }
  after_initialize :init_role, if: :new_record?

  def init_role
    self.role ||= :user
  end
end
