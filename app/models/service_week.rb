class ServiceWeek < ApplicationRecord
  has_many :service_days, dependent: :destroy
  belongs_to :service
  
  validates :service_days, length: { maximum: 7 }
end
