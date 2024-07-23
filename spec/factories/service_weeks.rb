FactoryBot.define do
  factory :service_week do
    sequence(:id) { |n| n }
    sequence(:week) { |n| n % 52 }
    association :service, factory: :service

    transient do
      days_count { 7 }
    end

    factory :service_week_with_days_and_hours do
      after(:create) do |service_week, evaluator|
        create_list(:service_day_with_hours, evaluator.days_count, service_week:)
      end
    end
  end
end
