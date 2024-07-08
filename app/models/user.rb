class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # validates :name, presence: true, uniqueness: true
  # validates :email, presence: true, uniqueness: true
  # validates :password, presence: true, length: { minimum: 6, maximum: 64 }, letters_and_numbers: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self
end
