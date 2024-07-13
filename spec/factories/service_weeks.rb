FactoryBot.define do
  factory :service_week do
    sequence(:id) { |n| n }
    sequence(:week) { |n| n }
    association :service, factory: :service
  end
end
