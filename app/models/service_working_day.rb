class ServiceWorkingDay < ApplicationRecord
  belongs_to :service

  validates :day, presence: true, inclusion: { in: 1..7 }, uniqueness: { scope: :service_id }
  validates :from, presence: true, inclusion: { in: 0..23 }
  validates :to, presence: true, inclusion: { in: 0..23 },
                 numericality: { greater_than_or_equal_to: :from, if: proc { |service|
                                                                        service.from.present?
                                                                      } }
end
