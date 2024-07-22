class ServiceHourUser < ApplicationRecord
  belongs_to :service_hour
  belongs_to :user
end
