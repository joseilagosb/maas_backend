FactoryBot.define do
  factory :service do
    sequence(:id) { |n| n }
    name {"#{Faker::App.name} financing"}
    from {Date.new(2022, 1, 1)}
    to {Date.new(2022, 5, 31)}
  end
end
