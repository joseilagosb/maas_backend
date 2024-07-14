require 'faker'

p 'Eliminando datos anteriores... (esto puede tomar unos segundos)'

ServiceDay.destroy_all
ServiceHour.destroy_all
ServiceWeek.destroy_all
ServiceWorkingDay.destroy_all
Service.destroy_all
User.destroy_all

p 'Creando usuarios...'

users = User.create!([
  { name: "Messi", email: "messi@maas.com", password: 'contrasena', color: :blue },
  { name: "Neymar", email: "neymar@maas.com", password: 'contrasena', color: :yellow },
  { name: "Ronaldo", email: "cristiano@maas.com", password: 'contrasena', color: :red },
])
admins = User.create!([
  { name: "Pepe", email: "pepe@maas.com", password: 'contrasena_admin', role: :admin, color: :green },
])

service_type = ["mobile", "analytics", "web", "api", "financial"]

service_hours = [
  { weekdays: (17..22).to_a, weekends: (12..23).to_a },
  { weekdays: (13..20).to_a, weekends: (10..20).to_a },
  { weekdays: (9..15).to_a, weekends: (15..23).to_a },
]

p 'Creando servicios... (esto si va a tomar harto tiempo)'

3.times do |index|
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
  weeks = (1..(current_week + 1)).to_a
  weeks.each do |week|
    service_week = service.service_weeks.build({ week: week })
    days = (1..7).to_a
    days.each do |day| 
      service_day = service_week.service_days.build({ day: day })
      weekdayHours = service_hours[index][:weekdays]
      weekendHours = service_hours[index][:weekends]
      
      case day
      when 1..5
        weekdayHours.each do |hour|
          designated_user = users.sample
          users_not_designated = users.excluding(designated_user)
          available_users = users_not_designated.sample((0..(users_not_designated.length)).to_a.sample)

          service_hour = service_day.service_hours.build({ 
              hour: hour, 
              designated_user: users.sample,
           })
          service_hour.users << designated_user
          available_users.each do |available_user| 
            service_hour.users << available_user
          end
        end
      else
        weekendHours.each do |hour|
          designated_user = users.sample
          users_not_designated = users.excluding(designated_user)
          available_users = users_not_designated.sample((0..(users_not_designated.length)).to_a.sample)
          available_users << designated_user

          service_hour = service_day.service_hours.build({ 
            hour: hour, 
            designated_user: users.sample,
          })
          service_hour.users << designated_user
          available_users.each do |available_user| 
            service_hour.users << available_user
          end
        end
      end
    end
  end

  service.save!
end

puts 'Seeds insertados con éxito'