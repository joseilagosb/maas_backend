class ShiftSchedulerService
  attr_reader :availability_hash, :shifts, :remaining_hours, :remaining_hours_by_user, :hours_by_user

  def initialize(availability_hash, service_id, week)
    @availability = AvailableIntervalsManager.build(availability_hash)
    initialize_data(service_id, week)
  end

  def call
    initial_fill_up_week
    second_round
    third_round
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
                   .select { |user, _remaining_hours| @availability[next_day].key?(user) }
                   .max_by { |_user, remaining_hours| remaining_hours }
    end
  end

  def second_round
    puts_balancing_data('Initial shifts distribution:')

    @shifts.each do |day, hours|
      # Try to fit remaining availability intervals for the day
      remaining_intervals = @availability[day] || {}
      empty_hours = hours.select { |_hour, user| user.nil? }.keys
      number_of_occupied_hours = hours.length - empty_hours.length

      interval_occurences_hash = {}

      # First we find the interval(s) that can fit the best given the empty hours in the day
      empty_hours.each do |element|
        remaining_intervals.each do |user_id, intervals|
          next if intervals.blank?

          intervals.each do |interval|
            next unless element >= interval[0] && element <= interval[1]

            interval_occurences_hash[interval[0]] = {} if interval_occurences_hash[interval[0]].nil?

            if interval_occurences_hash[interval[0]][interval[1]].nil?
              interval_occurences_hash[interval[0]][interval[1]] =
                { occurences: 0, users: [] }
            end

            interval_occurences_hash[interval[0]][interval[1]][:occurences] += 1
            unless interval_occurences_hash[interval[0]][interval[1]][:users].include?(user_id)
              interval_occurences_hash[interval[0]][interval[1]][:users] << user_id
            end
          end
        end
      end

      selected_interval = [nil, nil]
      selected_user = nil
      max_occurences = 0

      interval_occurences_hash.each do |start_interval, end_intervals|
        end_intervals.each do |end_interval, details|
          next unless details[:occurences] > max_occurences

          max_occurences = details[:occurences]
          selected_interval = [start_interval, end_interval]
          selected_user = details[:users].max_by { |user_id| @remaining_hours_by_user[user_id] }
        end
      end

      next if selected_interval.empty?

      # We adjust the shifts hash with the new interval, merging the two blocks if needed
      # (that will involve removing hours from the original block)
      left = selected_interval[0]
      right = selected_interval[1]

      while left <= right
        if hours[left].nil? && hours[right].nil?
          left += 1
          right -= 1
          next
        end

        number_of_nulls = hours.select { |hour, user| hour >= left && hour <= right && user.nil? }.length

        if !hours[left].nil? && !hours[right].nil?
          orientation = %i[left-to-right right-to-left].sample

          if orientation == 'left-to-right'
            unless selected_interval[1] - selected_interval[0] < (number_of_occupied_hours)
              selected_interval[1] -= ((number_of_occupied_hours + number_of_nulls + left - selected_interval[0]) / 2)
            end
          else
            unless selected_interval[1] - selected_interval[0] < (number_of_occupied_hours)
              selected_interval[1] -= ((number_of_occupied_hours + number_of_nulls + left - selected_interval[0]) / 2) + 1
            end
          end

          break
        end

        if hours[left].nil?
          unless selected_interval[1] - selected_interval[0] < (number_of_occupied_hours)
            selected_interval[1] -= ((number_of_occupied_hours + number_of_nulls + left - selected_interval[0]) / 2) + 1
          end

          break
        end
        if hours[right].nil?
          unless selected_interval[1] - selected_interval[0] < (number_of_occupied_hours)
            selected_interval[0] += ((number_of_occupied_hours + number_of_nulls + selected_interval[1] - right) / 2) - 1
          end

          break
        end
        left += 1
        right -= 1
      end

      assign_user_to_hours_interval(selected_user, day, selected_interval)
    end
  end

  # The THIRD ITERATION (optional) adjusts the final shifts distribution depending if there's a high
  # inequality among the users in the schedule.
  def third_round
    # Finally, we check whether there's an user whose number is highly unbalanced compared with the others

    puts_balancing_data('Initial shifts distribution (Third round):')
  end

  def puts_balancing_data(message)
    puts message
    @shifts.each do |day, hours|
      puts "day: #{day}, hours: #{hours}"
    end
    puts "remaining hours by user: #{@remaining_hours_by_user}"
    puts "hours by user: #{@hours_by_user}"
    puts "quedan #{@remaining_hours} horas"
    puts "remaining availability: #{@availability}"
    puts '-------------'
    puts '-------------'
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
      @shifts[day][hour] = user

      @remaining_hours_by_user[user] -= 1
      @remaining_hours_by_user[previous_user] += 1 if previous_user

      @hours_by_user[user] += 1
      @hours_by_user[previous_user] -= 1 if previous_user

      @remaining_hours -= 1 unless previous_user
    end
  end

  def initialize_data(service_id, week)
    @shifts = initialize_shifts(service_id, week)
    @remaining_hours = @shifts.values.sum { |day| day.keys.count }
    @remaining_hours_by_user = all_available_users.index_with(@remaining_hours / all_available_users.size)
    @hours_by_user = all_available_users.index_with(0)
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
