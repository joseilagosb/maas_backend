FactoryBot.define do
  factory :user_hours_assignment do
    sequence(:id) { 2 }
    name { "pepe" }
    color { "green" }
    hours_count { 1 }
  end
end