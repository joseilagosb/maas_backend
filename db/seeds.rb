require 'faker'

p 'Eliminando datos anteriores... (esto puede tardar unos segundos)'

ServiceHour.destroy_all
ServiceDay.destroy_all
ServiceWeek.destroy_all
Service.destroy_all

User.destroy_all

p 'Creando usuarios...'

User.create!([
  { name: "Lionel messi", email: "messi@maas.com", password: 'contrasena' },
  { name: "Neymar", email: "neymar@maas.com", password: 'contrasena' },
  { name: "Cristiano ronaldo", email: "cristiano@maas.com", password: 'contrasena' },
  { name: "Pepe", email: "pepe@maas.com", password: 'contrasena_admin', role: :admin },
])

service_type = ["mobile", "analytics", "web", "api", "financial"]
users = User.all

p 'Creando servicios...'

6.times do
  service = Service.new({ name: "#{Faker::App.name} #{service_type.sample}" })

  current_week = Time.now.strftime("%U").to_i
  weeks = (0..current_week).to_a
  weeks.each do |w|
    service_week = service.service_weeks.build({ week: w })
    days = (1..7).to_a
    days.each do |d| 
      service_day = service_week.service_days.build({ day: d })
      weekdayHours = (17..22).to_a
      weekendHours = (12..23).to_a
      
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