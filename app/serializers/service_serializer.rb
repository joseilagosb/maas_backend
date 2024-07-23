class ServiceSerializer
  include JSONAPI::Serializer
  attributes :id, :name, :active

  has_many :service_weeks, if: proc { |_, params| params[:method] == :show }
  has_many :service_working_days, if: proc { |_, params| params[:method] == :show }
end
