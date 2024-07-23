FactoryBot.define do
  factory :service_working_day do
    sequence(:id) { |n| n }
    sequence(:day) { |n| n % (7 - 1) }
    sequence(:from) { 16 }
    sequence(:to) { 22 }
    association :service, factory: :service
  end
end
