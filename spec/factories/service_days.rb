FactoryBot.define do
  factory :service_day do
    sequence(:id) { |n| n }
    sequence(:day) { |n| n }
  end
end
