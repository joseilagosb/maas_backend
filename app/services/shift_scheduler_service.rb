class ShiftSchedulerService
  attr_reader :availability_hash, :shifts, :remaining_hours, :remaining_hours_by_user

  def initialize(availability_hash, service_id, week)
    @availability = AvailableIntervalsManager.build(availability_hash)
    initialize_data(service_id, week)
  end

  def call
    initial_fill_up_week
    second_round
  end

  private

  # This describes the FIRST ITERATION of the algorithm, filling up each day with a random user's available hours
  # Being a preliminary step, the resulting shifts hash will present the following concerns:
  # - Filling up the entirety of the hours (all users with 0 remaining hours) but not filling all hours of
  # the service week
  # - Not filling up the entirety of remaining hours for all users -> unbalanced distribution
  # - Filling up a user (or multiple users) with more hours than expected (i.e. having remaining hours lower
  # than zero) -> unbalanced distribution
  # Those concerns will be addressed by the second round of the algorithm
  def initial_fill_up_week
    randomized_days = @shifts.keys.shuffle + [nil]

    # we select a random user for the first iteration
    next_user = @remaining_hours_by_user
                .select { |user, _hours| @availability[randomized_days.first].key?(user) }
                .keys
                .sample

    randomized_days.each_cons(2) do |day, next_day|
      # we assign the hours from the selected user to the shifts hash
      next_interval = hours_interval_for_user(next_user, day)
      assign_user_to_hours_interval(next_user, day, next_interval)

      # We look for the next user in the iteration, the one with the most remaining hours in the
      # remaining_hours_by_user hash
      # This will be done while we're not in the last day of the week
      break if next_day.nil?

      next_user, = @remaining_hours_by_user
                   .select { |user, _hours| @availability[next_day].key?(user) }
                   .max_by { |_user, hours| hours }
    end
  end

  def second_round
    @shifts.each do |day, hours|
      puts "day: #{day}, hours: #{hours}"
    end
    puts "remaining hours by user: #{@remaining_hours_by_user}"
    puts "quedan #{@remaining_hours} horas"

    puts "remaining availability: #{@availability}"
  end

  # we select (and pop) the last interval in the availability hash
  # since the availability hash was shuffled in initialization, we can be sure it'll be a random interval
  def hours_interval_for_user(user, day)
    chosen_interval = @availability[day][user].pop

    # we clear that day if no users available for that day, that means no modifications can be done to that day
    @availability[day].delete(user) if @availability[day][user].empty?

    chosen_interval
  end

  def assign_user_to_hours_interval(user, day, hours_interval)
    (hours_interval[0]..hours_interval[1]).each do |hour|
      previous_user = @shifts[day][hour]

      @remaining_hours_by_user[previous_user] += 1 if previous_user

      @shifts[day][hour] = user
      @remaining_hours_by_user[user] -= 1
      @remaining_hours -= 1
    end
  end

  def initialize_data(service_id, week)
    @shifts = initialize_shifts(service_id, week)
    @remaining_hours = @shifts.values.sum { |day| day.keys.count }
    @remaining_hours_by_user = all_available_users.index_with(@remaining_hours / all_available_users.size)
  end

  def initialize_shifts(service_id, week)
    service_week = ServiceWeek.includes(service_days: :service_hours).find_by(service_id:, week:)
    service_week.service_days.each_with_object({}) do |service_day, result|
      result[service_day.day] = service_day.service_hours.each_with_object({}) do |service_hour, day_result|
        day_result[service_hour.hour] = nil
      end
    end
  end

  def all_available_users
    @availability.values.map(&:keys).flatten.uniq
  end
end
