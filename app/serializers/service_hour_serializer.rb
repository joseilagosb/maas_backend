class ServiceHourSerializer
  include JSONAPI::Serializer

  attributes :id, :hour

  belongs_to :designated_user, serializer: UserSerializer, if: proc { |_, params| params[:method] == :show }
  has_many :users, if: proc { |_, params| params[:method] == :edit }
end
