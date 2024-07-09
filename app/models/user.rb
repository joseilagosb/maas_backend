class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  validates :name, presence: true, uniqueness: true

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :jwt_authenticatable, jwt_revocation_strategy: self
  devise :validatable, password_length: 6..64
end
