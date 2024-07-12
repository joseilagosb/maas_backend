class Service < ApplicationRecord
  has_many :service_weeks, dependent: :destroy
end
