FactoryBot.define do
  factory :base_service, class: 'Service' do
    sequence(:id) { |n| n }
    name { "#{Faker::App.name} financing" }

    factory :service do
      active { true }
      factory :service_with_weeks_and_working_days do
        transient do
          minimal { false }
          service_weeks_count { minimal ? 1 : Time.now.strftime('%U').to_i }
          working_days_count { minimal ? 1 : 7 }
        end
  
        after(:create) do |service, evaluator|
          create_list(:service_week, evaluator.service_weeks_count, service:)
          create_list(:service_working_day, evaluator.working_days_count, service:)
        end
      end
    end

    factory :service_without_active do
    end
  end
end
