FactoryBot.define do
  factory :service_hour do
    sequence(:id) { |n| n }
    sequence(:hour, (0..23).cycle) { |n| n }
    association :designated_user, factory: :user
    service_day

    factory :service_hour_with_users do
      designated_user { User.all.sample || nil }

      after(:create) do |service_hour|
        users_except_designated = User.where.not(id: service_hour.designated_user.id)
        service_hour.users << users_except_designated.sample(rand(0..User.count - 1))
        service_hour.users << service_hour.designated_user
      end
    end
  end
end
