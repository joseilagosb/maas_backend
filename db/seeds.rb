require 'faker'

# Method to generate random availability intervals
def random_availability_intervals
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
  service = Service.new({ name: "#{Faker::App.name} #{service_type.sample}" })

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
    user_availabilities = {
      users[0].id => (1..7).map { |day| [day, random_availability_intervals] }.to_h,
      users[1].id => (1..7).map { |day| [day, random_availability_intervals] }.to_h,
      users[2].id => (1..7).map { |day| [day, random_availability_intervals] }.to_h
    }
    
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