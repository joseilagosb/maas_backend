FactoryBot.define do
  factory :user do
    name {"pepe" }
    email { "pepe@maas.com" }
    password { Faker::Internet.password(min_length: 6, max_length: 64) }
  end

  factory :admin, parent: :user do
    role { :admin }
  end
end
