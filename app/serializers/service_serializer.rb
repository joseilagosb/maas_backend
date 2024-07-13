class ServiceSerializer
  include JSONAPI::Serializer
  attributes :id, :name, :active

  has_many :service_weeks
  has_many :service_working_days
end
