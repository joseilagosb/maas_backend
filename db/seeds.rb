require 'faker'

def random_availability_intervals__OLD
  intervals = []
  
  # Decide if the user is unavailable on this day (e.g., 10% chance)
  return intervals if rand < 0.1

  # Start by assigning a larger interval
  first_interval_start = rand(8..10)
  first_interval_end = rand((first_interval_start + 4)..17)
  intervals << (first_interval_start..first_interval_end)

  # Potentially add a second interval if it doesn't overlap with the first
  if rand < 0.7 # 70% chance of having a second interval
    second_interval_start = rand((first_interval_end + 1)..19)
    second_interval_end = rand([second_interval_start + 2, 22].min..22)
    intervals << (second_interval_start..second_interval_end) unless first_interval_end >= second_interval_start
  end

  # If the intervals don't cover enough hours, extend one of them
  total_hours_covered = intervals.sum { |interval| interval.size }
  if total_hours_covered < 10 && rand < 0.5
    intervals[0] = (first_interval_start..[first_interval_end + (10 - total_hours_covered), 22].min)
  end

  intervals
end

# Method to generate random availability intervals
def random_availability_intervals(hours)
  # If there are no hours (it's not a working day), return an empty array
  return [] if hours.empty?

  # Decide if the user is unavailable on this day (10% chance)
  return [] if rand < 0.1

  day_start = hours.first
  day_end = hours.last
  intervals = []

  # Start by assigning a larger interval
  position = 'up'
  if rand < 0.5
    first_interval_start = rand(day_start..day_start + 2)
    first_interval_end = rand(day_end - (hours.size / 2)..day_end)
  else
    position = 'down'
    first_interval_end = rand(day_end - 2..day_end)
    first_interval_start = rand(day_start..day_start + (hours.size / 2))
  end

  remaining_hours = hours.size - first_interval_end - first_interval_start + 1

  # If there are too few unavailable hours, assign the whole day instead
  if remaining_hours < 3 && (rand < 0.3 && hours.size < 10) && (rand < 0.6 && hours.size >= 10)
    return [(day_start..day_end)]
  end

  # If the interval is too small, we extend it to the left and right (if possible)
  if first_interval_end - first_interval_start + 1 < 3
    extra_hours = 0

    while extra_hours < 2 && (first_interval_start > day_start && first_interval_end < day_end)
      if first_interval_start > day_start
        first_interval_start -= 1
        extra_hours += 1
      end
      if first_interval_end < day_end
        first_interval_end += 1
        extra_hours += 1
      end
    end
  end

  intervals << (first_interval_start..first_interval_end)

  intervals
end


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

SERVICES_LENGTH = 3

USERS_LENGTH = 3

service_type = ["mobile", "analytics", "web", "api", "financial"]

service_descriptions = [
  "Plataforma colaborativa para la planificación, ejecución y seguimiento de proyectos, con herramientas de gestión de tareas, tiempos y recursos.",
  "Servicio avanzado de análisis y visualización de datos, que permite a las empresas obtener insights clave a partir de grandes volúmenes de información.",
  "Solución completa para tiendas en línea, con integración de pasarelas de pago, gestión de inventarios y personalización de la experiencia de compra.",
  "Plataforma que permite automatizar campañas de marketing por correo electrónico, redes sociales y más, optimizando el alcance y la conversión de clientes.",
  "Sistema integral para la administración de recursos humanos, incluyendo el seguimiento de nóminas, vacaciones y evaluaciones de desempeño.",
  "Aplicación de gestión de inventarios que permite a las empresas rastrear y administrar sus existencias en tiempo real, optimizando la cadena de suministro.",
  "Plataforma de gestión de clientes (CRM) que ayuda a las empresas a gestionar interacciones con clientes y prospectos, mejorando la retención y satisfacción del cliente.",
  "Sistema de reservas en línea que permite a negocios de diferentes sectores gestionar y automatizar la programación de citas y reservas de servicios.",
  "Servicio de desarrollo de aplicaciones móviles personalizadas que ofrece soluciones a medida para iOS y Android, mejorando la experiencia del usuario en dispositivos móviles.",
  "Herramienta de colaboración en línea que integra funciones de chat, videoconferencia y compartición de documentos para facilitar el trabajo en equipo y la comunicación remota."
]

selected_service_descriptions = service_descriptions.sample(SERVICES_LENGTH)

service_hours = [
  { weekdays: (17..22).to_a, weekends: (12..23).to_a },
  { weekdays: (13..20).to_a, weekends: (10..20).to_a },
  { weekdays: (9..15).to_a, weekends: [] },
]

# Method to find available users for a given hour and day
def available_users_for_hour(hour, day, user_availabilities)
  user_availabilities.select do |user_id, availability|
    intervals = availability[day]
    intervals.any? { |interval| interval.include?(hour) } unless intervals.empty?
  end.keys
end


################################################################################
# SEEDS CODE STARTS HERE
################################################################################

p 'Creando servicios...'

services = Array.new(SERVICES_LENGTH) do |index|
  p "Creando servicio #{index + 1}"
  service = Service.new({ name: "#{Faker::App.name} #{service_type.sample}", description: selected_service_descriptions[index] })

  if !service_hours[index][:weekdays].empty?
    (1..5).to_a.each do |working_day|
      service.service_working_days.build({ 
          day: working_day, 
          from: service_hours[index][:weekdays].first, 
          to: service_hours[index][:weekdays].last 
      })
    end
  end

  if !service_hours[index][:weekends].empty?
    (6..7).to_a.each do |working_day| 
      service.service_working_days.build({ 
          day: working_day, 
          from: service_hours[index][:weekends].first, 
          to: service_hours[index][:weekends].last 
      })
    end
  end

  current_week = Time.now.strftime("%U").to_i
  
  starting_week = rand(15..(current_week + 1))
  ending_week = current_week + 1

  weeks = (starting_week..ending_week).to_a
  weeks.each do |week|
    service_week = service.service_weeks.build({ week: week })

    # Generate a unique schedule for each user
    user_availabilities = users.each.map do |user|
      availability = (1..7).map do |day|
        hours = if (1..5).include?(day)
                  service_hours[index][:weekdays]
                else
                  service_hours[index][:weekends]
                end
        [day, random_availability_intervals(hours)]
      end.to_h
      [user.id, availability]
    end.to_h
    
    days = []
    days.concat (1..5).to_a unless service_hours[index][:weekdays].empty?
    days.concat (6..7).to_a unless service_hours[index][:weekends].empty?
    
    days.each do |day| 
      service_day = service_week.service_days.build({ day: day })

      hours = day <= 5 ? service_hours[index][:weekdays] : service_hours[index][:weekends]

      hours.each do |hour|
        available_user_ids = available_users_for_hour(hour, day, user_availabilities)

        if available_user_ids.any?
          # Get a random user ID from the available user IDs
          random_user_id = available_user_ids.sample
          
          # Find the user instance corresponding to that ID
          designated_user = users.find { |u| u.id == random_user_id }
          
          # Ensure that available_users includes the designated user and any other users
          available_users = users.select { |u| available_user_ids.include?(u.id) }
        else
          designated_user = nil
          available_users = []
        end
    
        service_hour = service_day.service_hours.build({ 
          hour: hour, 
          designated_user: designated_user,
          users: available_users
        })
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