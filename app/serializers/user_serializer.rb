class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :name, :role, :color
end
