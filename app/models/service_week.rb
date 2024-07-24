class ServiceWeek < ApplicationRecord
  has_many :service_days, dependent: :destroy
  belongs_to :service

  validates :week, presence: true, inclusion: { in: 1..53 }, uniqueness: { scope: :service_id }
  validates :service_days, length: { maximum: 7 }
end
