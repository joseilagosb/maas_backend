require 'faker'

p 'Eliminando datos anteriores... (esto puede tomar unos segundos)'

ServiceWorkingDay.destroy_all
ServiceHour.destroy_all
ServiceDay.destroy_all
ServiceWeek.destroy_all
Service.destroy_all

User.destroy_all

p 'Creando usuarios...'

User.create!([
  { name: "Lionel messi", email: "messi@maas.com", password: 'contrasena', color: :blue },
  { name: "Neymar", email: "neymar@maas.com", password: 'contrasena', color: :yellow },
  { name: "Cristiano ronaldo", email: "cristiano@maas.com", password: 'contrasena', color: :red },
  { name: "Pepe", email: "pepe@maas.com", password: 'contrasena_admin', role: :admin, color: :green },
])

# TODO: quitar al admin de los service hours

service_type = ["mobile", "analytics", "web", "api", "financial"]
users = User.all

service_hours = [
  { weekdays: (17..22).to_a, weekends: (12..23).to_a },
  { weekdays: (13..20).to_a, weekends: (10..20).to_a },
  { weekdays: (9..15).to_a, weekends: (15..23).to_a },
]

p 'Creando servicios...'

3.times do |index|
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
  weeks.each do |w|
    service_week = service.service_weeks.build({ week: w })
    days = (1..7).to_a
    days.each do |d| 
      service_day = service_week.service_days.build({ day: d })
      weekdayHours = service_hours[index][:weekdays]
      weekendHours = service_hours[index][:weekends] 
      
      case d
      when 1..5
        weekdayHours.each { |h| service_day.service_hours.build({ hour: h, user: users.sample }) }
      else
        weekendHours.each { |h| service_day.service_hours.build({ hour: h, user: users.sample }) }
      end
    end
  end

  service.save!
end

puts 'Seeds insertados con éxito'