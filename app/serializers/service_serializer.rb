class ServiceSerializer
  include JSONAPI::Serializer
  attributes :id, :name, :active

  has_many :service_weeks
end
