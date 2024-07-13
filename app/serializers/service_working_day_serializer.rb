class ServiceWorkingDaySerializer
  include JSONAPI::Serializer
  attributes :id, :day, :from, :to

  belongs_to :service
end
