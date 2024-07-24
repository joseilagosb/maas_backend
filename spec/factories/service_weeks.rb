FactoryBot.define do
  factory :service_week do
    sequence(:id) { |n| n }
    sequence(:week, (1..53).cycle) { |n| n }
    service

    transient do
      minimal { false }
      days_count { minimal ? 1 : 7 }
    end

    factory :service_week_with_days_and_hours do
      after(:create) do |service_week, evaluator|
        create_list(:service_day_with_hours, evaluator.days_count, service_week:, minimal: evaluator.minimal)
      end
    end
  end
end
