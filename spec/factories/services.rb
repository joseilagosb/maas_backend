FactoryBot.define do
  factory :service do
    sequence(:id) { |n| n }
    name {"#{Faker::App.name} financing"}
    from {Date.new(2022, 1, 1).rfc2822}
    to {Date.new(2022, 5, 31).rfc2822}
  end

  factory :serialized_service do
    type {"service"}
    attributes {
      {
        name: service.name,
        from: service.from,
        to: service.to
      }
    }
  end
end
