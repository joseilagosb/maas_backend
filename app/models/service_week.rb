class ServiceWeek < ApplicationRecord
  has_many :service_days, dependent: :destroy
  belongs_to :service
end
