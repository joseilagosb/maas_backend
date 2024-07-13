FactoryBot.define do
  factory :service do
    sequence(:id) { |n| n }
    name {"#{Faker::App.name} financing"}
    active {true}

    transient do
      service_weeks_count {Time.now.strftime("%U").to_i}
    end

    after(:create) do |service, evaluator|
      create_list(:service_week, evaluator.service_weeks_count, service: service)
    end
  end
end
