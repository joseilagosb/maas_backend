class ServiceDaySerializer
  include JSONAPI::Serializer
  attributes :id, :day

  has_many :service_hours do |service_day|
    service_day.service_hours.order(id: :asc)
  end
end
