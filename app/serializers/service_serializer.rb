class ServiceSerializer
  include JSONAPI::Serializer
  attributes :id, :name, :from, :to
end
