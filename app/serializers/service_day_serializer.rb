class ServiceDaySerializer
  include JSONAPI::Serializer
  attributes :id, :day

  has_many :service_hours
end
