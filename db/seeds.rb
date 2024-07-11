require 'faker'

User.destroy_all

User.create!([
  { name: "Lionel messi", email: "messi@maas.com", password: 'contrasena' },
  { name: "Neymar", email: "neymar@maas.com", password: 'contrasena' },
  { name: "Cristiano ronaldo", email: "cristiano@maas.com", password: 'contrasena' },
  { name: "Pepe", email: "pepe@maas.com", password: 'contrasena_admin', role: :admin },
])

Service.destroy_all

15.times do
  Service.create({ name: "#{Faker::App.name} financing", from: Date.new(2022, 1, 1), to: Date.new(2022, 5, 31) })
  Service.create({ name: "#{Faker::App.name} mobile", from: Date.new(2022, 2, 1), to: Date.new(2022, 4, 30) })
  Service.create({ name: "#{Faker::App.name} analytics", from: Date.new(2022, 3, 1), to: Date.new(2022, 9, 30) })
end

puts 'Seeds insertados con éxito'