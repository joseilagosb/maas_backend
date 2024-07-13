FactoryBot.define do
  factory :service_hour do
    sequence(:id) { |n| n }
    sequence(:hour) { |n| n + 10 }
    user
  end
end
