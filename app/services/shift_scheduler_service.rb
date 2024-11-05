class ShiftSchedulerService
  def initialize(availability_hash, service_id, week)
    @availability = AvailableIntervalsCreator.build(availability_hash)
    initialize_data(service_id, week)
    @options = { max_finetuning_iterations: 3 }
  end

  def call
    filling_round
    merging_round
    finetuning_round
    Logging::ShiftSchedulerLogger.call(@shifts, @remaining_hours_by_user, @hours_by_user, @remaining_hours,
                                       @availability, 'Final shifts distribution')
  end

  private

  # Runs the FIRST ROUND of the algorithm, filling up each day with a random user's available hours.
  # As a result there will be an assigned user by day (unless any user is available in a day)

  # Being a preliminary step, the resulting shifts hash will present the following concerns:
  # - Filling up the entirety of the hours (all users with 0 remaining hours) but not filling all hours of
  # the service week
  # - Not filling up the entirety of remaining hours for all users -> unbalanced distribution
  # - Filling up a user (or multiple users) with more hours than expected (i.e. having remaining hours lower
  # than zero) -> unbalanced distribution

  # Those concerns will be addressed by the second round of the algorithm
  def filling_round
    randomized_days = @shifts.keys.shuffle + [nil]

    # we select a random user for the first iteration
    next_user = @remaining_hours_by_user
                .select { |user, _hours| @availability[randomized_days.first].key?(user) }
                .keys
                .sample

    randomized_days.each_cons(2) do |day, next_day|
      # we assign the hours from the selected user to the shifts hash
      next_interval = IntervalsManager.pop_interval(@availability, day, next_user)
      assign_user_to_hours_interval(next_user, day, next_interval)

      # As long as it's not the last day of the week...
      break if next_day.nil?

      # We'll look for the next user in the iteration with the highest number of remaining hours
      next_user, = @remaining_hours_by_user
                   .select { |user, _remaining_hours| @availability[next_day].key?(user) }
                   .max_by { |_user, remaining_hours| remaining_hours }
    end
  end

  # The SECOND ROUND of the algorithm traverses the shifts hash again and adds a second user (if possible) to
  # reduce the number of empty hours and increase the number of shifts in a day.

  # This addresses the concerns of unoccuppied hours due to the preliminary nature of the first round, however
  # it doesn't tackle the potential imbalance of the distribution of hours between users.
  def merging_round
    Logging::ShiftSchedulerLogger.call(@shifts, @remaining_hours_by_user, @hours_by_user, @remaining_hours,
                                       @availability, 'Initial shifts distribution (second round)')

    @shifts.each do |day, hours|
      remaining_intervals = @availability[day] || {}
      empty_hours = hours.select { |_hour, user| user.nil? }.keys

      next if empty_hours.empty?

      # We look for the best interval to fit the remaining hours in the day
      selected_interval, selected_user = BestIntervalFinder.build(@remaining_hours_by_user, empty_hours,
                                                                  remaining_intervals)

      next if selected_interval.blank?

      # we remove the selected interval since it's going to be added
      selected_interval = IntervalsManager.remove_interval(@availability, day, selected_user, selected_interval)

      # we adjust the start and end boundaries of the interval to fit in the shifts hash
      # and maintain balance with the existing user
      adjusted_interval = IntervalBoundariesAdjuster.build(hours, selected_interval)

      # we finally add the adjusted interval to the shifts hash
      assign_user_to_hours_interval(selected_user, day, adjusted_interval)

      remainder_interval = IntervalsManager.remainder_between_intervals_compact(selected_interval, adjusted_interval)

      # and add the extracted portion back to the shifts hash
      if remainder_interval.present?
        IntervalsManager.add_interval(@availability, day, selected_user,
                                      remainder_interval)
      end
    end
  end

  # The THIRD ITERATION adjusts the final shifts distribution depending if there's a high imbalance among the
  # users in the schedule.

  # This addresses any imbalance of the distribution of hours between users and its output serves as the final
  # result of the algorithm.
  def finetuning_round
    Logging::ShiftSchedulerLogger.call(@shifts, @remaining_hours_by_user, @hours_by_user, @remaining_hours,
                                       @availability, 'Initial shifts distribution (third round)')

    iterations = 0

    # TODO: figure out a way to stop the algorithm if it's not going to improve the shifts distribution
    while @options[:max_finetuning_iterations] > iterations && unbalanced_users.present?
      sorted_users = users_by_remaining_hours

      user_to_remove = sorted_users.last
      user_to_add = sorted_users.first

      required_hours_to_remove = @remaining_hours_by_user[user_to_remove].abs

      break if required_hours_to_remove < 3

      puts "shifts: #{@shifts}, user remaining intervals: #{user_remaining_intervals(user_to_add)}, user_to_add: #{user_to_add}, user_to_remove: #{user_to_remove}, required_hours_to_remove: #{@remaining_hours_by_user[user_to_remove].abs}"

      # - the candidate/user_to_remove needs a certain amount of hours to be removed from the shifts hash
      # to regain balance
      # - the user/user_to_add needs to be added to the shifts hash
      resulting_days, resulting_intervals = ShiftsFinetuningManager.build(@shifts,
                                                                          user_remaining_intervals(user_to_add),
                                                                          user_to_add,
                                                                          user_to_remove,
                                                                          @remaining_hours_by_user[user_to_remove].abs)

      puts "resulting days: #{resulting_days}", "resulting intervals: #{resulting_intervals}"

      resulting_days.each_with_index do |day, index|
        IntervalsManager.remove_interval(@availability, day, user_to_add, resulting_intervals[index])
        assign_user_to_hours_interval(user_to_add, day, resulting_intervals[index])
      end

      iterations += 1
    end
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

      # we add the user back to the availability hash if there was a previous user in the shifts hash
      IntervalsManager.add_interval(@availability, day, previous_user, [hour, hour]) if previous_user
    end
  end

  def unbalanced_users
    @remaining_hours_by_user.select { |_user, hours| hours.negative? }.keys
  end

  def users_by_remaining_hours
    @remaining_hours_by_user.sort_by { |_user, hours| hours }.reverse.map(&:first)
  end

  def user_remaining_intervals(user_id)
    @availability.select { |_day, hours| hours.key?(user_id) }
                 .reduce({}) { |result, (day, hours)| result.merge(day => hours[user_id]) }
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
