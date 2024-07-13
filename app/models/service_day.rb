class ServiceDay < ApplicationRecord
  has_many :service_hours, dependent: :destroy
  belongs_to :service_week
  
  validates :service_hours, length: { maximum: 24 }
end
