class ServiceHourSerializer
  include JSONAPI::Serializer
  attributes :id, :hour

  belongs_to :user
end
