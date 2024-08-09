FactoryBot.define do
  factory :user do
    name {"pepe" }
    email { "pepe@maas.com" }
    password { Faker::Internet.password(min_length: 6, max_length: 64) }
    color { 1 }
  end

  factory :admin, parent: :user do
    role { :admin }
  end

  factory :fake_user, class: User do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 6, max_length: 64) }
    color { rand(1..6) }
  end
end
