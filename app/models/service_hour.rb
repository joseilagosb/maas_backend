class ServiceHour < ApplicationRecord
  belongs_to :user
  belongs_to :service_day
end
