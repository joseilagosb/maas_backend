class ServiceDay < ApplicationRecord
  has_many :service_hours, dependent: :destroy
  belongs_to :service_week

  validates :day, presence: true, inclusion: { in: 1..7 }, uniqueness: { scope: :service_week_id }
  validates :service_hours, length: { maximum: 24 }
end
