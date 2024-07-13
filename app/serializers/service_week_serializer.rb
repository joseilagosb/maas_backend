class ServiceWeekSerializer
  include JSONAPI::Serializer
  attributes :id, :week

  has_many :service_days
  belongs_to :service
end
