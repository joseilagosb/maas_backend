FactoryBot.define do
  factory :service do
    sequence(:id) { |n| n }
    name { "#{Faker::App.name} financing" }
    active { true }

    transient do
      service_weeks_count { Time.now.strftime('%U').to_i }
      working_days_count { 7 }
    end

    factory :service_with_weeks_and_working_days do
      after(:create) do |service, evaluator|
        create_list(:service_week, evaluator.service_weeks_count, service:)
        create_list(:service_working_day, evaluator.working_days_count, service:)
      end
    end
  end
end
