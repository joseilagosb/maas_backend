FactoryBot.define do
  factory :service_working_day do
    sequence(:id) { |n| n }
    sequence(:day, (1..7).cycle) { |n| n }
    sequence(:from) { 16 }
    sequence(:to) { 22 }
    service
  end
end
