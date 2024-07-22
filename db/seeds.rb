require 'faker'

p 'Eliminando datos anteriores... (esto puede tomar unos segundos)'

ServiceHourUser.delete_all
ServiceHour.delete_all
ServiceDay.delete_all
ServiceWeek.delete_all
ServiceWorkingDay.delete_all
Service.delete_all
User.delete_all

p 'Creando usuarios...'

users = User.create!([
  { name: "Messi", email: "messi@maas.com", password: 'contrasena', color: :blue },
  { name: "Neymar", email: "neymar@maas.com", password: 'contrasena', color: :yellow },
  { name: "Ronaldo", email: "cristiano@maas.com", password: 'contrasena', color: :red },
])
admins = User.create!([
  { name: "Pepe", email: "pepe@maas.com", password: 'contrasena_admin', role: :admin, color: :green },
])

SERVICES_LENGTH = 5

USERS_LENGTH = 3

service_type = ["mobile", "analytics", "web", "api", "financial"]

service_hours = [
  { weekdays: (17..22).to_a, weekends: (12..23).to_a },
  { weekdays: (13..20).to_a, weekends: (10..20).to_a },
  { weekdays: (9..15).to_a, weekends: [] },
  { weekdays: [], weekends: (12..23).to_a },
  { weekdays: (9..18).to_a, weekends: [] },
]

p 'Creando servicios...'

services = Array.new(5) do |index|
  p "Creando servicio #{index + 1}"
  service = Service.new({ name: "#{Faker::App.name} #{service_type.sample}" })

  (1..5).to_a.each do |working_day|
    service.service_working_days.build({ 
        day: working_day, 
        from: service_hours[index][:weekdays].first, 
        to: service_hours[index][:weekdays].last 
    })
  end
  (6..7).to_a.each do |working_day| 
    service.service_working_days.build({ 
        day: working_day, 
        from: service_hours[index][:weekends].first, 
        to: service_hours[index][:weekends].last 
    })
  end

  current_week = Time.now.strftime("%U").to_i
  
  starting_week = rand(15..(current_week + 1))
  ending_week = current_week + 1

  weeks = (starting_week..ending_week).to_a
  weeks.each do |week|
    service_week = service.service_weeks.build({ week: week })
    days = (1..7).to_a
    days.each do |day| 
      service_day = service_week.service_days.build({ day: day })

      case day
      when 1..5
        service_hours[index][:weekdays].each do |hour|
          designated_user_index = rand(0..(USERS_LENGTH - 1))
          user_indexes_except_designated = (0..(USERS_LENGTH - 1)).to_a - [designated_user_index]
          available_users_indexes = user_indexes_except_designated.sample(rand(0..(user_indexes_except_designated.length)))
          available_users_indexes << designated_user_index

          service_hour = service_day.service_hours.build({ 
            hour: hour, 
            designated_user: users[designated_user_index],
            users: users.values_at(*available_users_indexes)
          })
        end
      else
        service_hours[index][:weekends].each do |hour|
          designated_user_index = rand(0..(USERS_LENGTH - 1))
          user_indexes_except_designated = (0..(USERS_LENGTH - 1)).to_a - [designated_user_index]
          available_users_indexes = user_indexes_except_designated.sample(rand(0..(user_indexes_except_designated.length)))
          available_users_indexes << designated_user_index

          service_hour = service_day.service_hours.build({ 
            hour: hour, 
            designated_user: users[designated_user_index],
            users: users.values_at(*available_users_indexes)
          })
        end
      end
    end
  end

  service
end

p 'Guardando en la base de datos...'

Service.transaction do
  services.each(&:save!)
end

p 'Seeds insertados con éxito'