FactoryBot.define do
  factory :service_day do
    sequence(:id) { |n| n }
    sequence(:day, (1..7).cycle) { |n| n }
    service_week

    transient do
      minimal { false }
      hours_count { minimal ? 1 : 10 }
    end

    factory :service_day_with_hours do
      after(:create) do |service_day, evaluator|
        create_list(:service_hour_with_users, evaluator.hours_count, service_day:)
      end
    end
  end
end
