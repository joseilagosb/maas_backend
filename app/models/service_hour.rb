class ServiceHour < ApplicationRecord
  belongs_to :service_day
  belongs_to :designated_user, class_name: 'User'

  has_many :available_users, class_name: 'User'

  has_many :service_hour_users, dependent: :destroy
  has_many :users, through: :service_hour_users

  validates :hour, presence: true, inclusion: { in: 0..23 }, uniqueness: { scope: :service_day_id }
end
