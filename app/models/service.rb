class Service < ApplicationRecord
  has_many :service_weeks, dependent: :destroy
  has_many :service_working_days, dependent: :destroy

  validates :service_working_days, length: { maximum: 7 }
end
