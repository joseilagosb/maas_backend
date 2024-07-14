class ServiceHour < ApplicationRecord
  belongs_to :service_day
  belongs_to :designated_user, class_name: 'User'
  
  has_many :available_users, class_name: 'User'
  has_and_belongs_to_many :users
end
