class UserAssignedHoursSerializer
  include JSONAPI::Serializer
  attributes :id, :color, :name, :hours_count
end
