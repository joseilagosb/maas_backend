# Finds the best candidate interval to balance the shifts hash's assigned hours by user. It does so by:
# - Finding the best interval to replace the removed user's hours
# - Adjusting the best interval to fit both the user to add and the user to remove in equal proportions (or close to it)

# The result of this is an interval to be promptly added to the shifts hash.
module ShiftScheduler
  class FinetuningIntervalsFinder
    def self.build(shifts, user_remaining_intervals, user_to_add, user_to_remove, required_hours_to_remove)
      new(shifts, user_remaining_intervals, user_to_add, user_to_remove, required_hours_to_remove).call
    end

    def initialize(shifts, user_remaining_intervals, user_to_add, user_to_remove, required_hours_to_remove)
      @shifts = shifts
      @user_remaining_intervals = user_remaining_intervals
      @user_to_add = user_to_add
      @user_to_remove = user_to_remove
      @remaining_hours = required_hours_to_remove
    end

    def call
      selected_days = []
      selected_intervals = []
      used_days = Set.new

      # Keep finding intervals until we meet the required hours or can't find more valid intervals
      while @remaining_hours.positive?
        day, interval = find_best_interval(used_days)
        break unless day && interval

        adjusted_interval = adjust_best_interval(day, interval)

        @remaining_hours -= Utils::Interval.length(adjusted_interval)

        selected_days << day
        selected_intervals << adjusted_interval
        used_days.add(day)
      end

      [selected_days, selected_intervals]
    end

    private

    # finds among the user remaining intervals the one that's the best fit to replace a occupied hour block
    def find_best_interval(used_days)
      best_day = nil
      best_interval = nil
      max_score = -1

      @shifts.each do |day, hours|
        next if used_days.include?(day)
        next unless @user_remaining_intervals[day]

        # we look for the hour sequences occupied by the user to remove
        user_occupied_interval = find_user_occupied_interval(hours, @user_to_remove)
        next if user_occupied_interval.nil? || Utils::Interval.length(user_occupied_interval) <= 3

        @user_remaining_intervals[day].each do |candidate_interval|
          # we discard the hour blocks occupied by more than one user that are too short to add an extra one
          next if multiple_user_hours?(hours) && hours.values.compact.count <= 7

          score = evaluate_interval(user_occupied_interval, candidate_interval)
          next unless score > max_score

          max_score = score
          best_day = day
          best_interval = candidate_interval
        end
      end

      [best_day, best_interval]
    end

    # adjusts the chosen best interval to fit and fulfill the constraints of the shifts hash
    def adjust_best_interval(best_day, best_interval)
      remainder_intervals, orientation = Utils::Interval.remainder_between_intervals(
        find_user_occupied_interval(@shifts[best_day], @user_to_remove),
        best_interval
      )

      # if there's no remainder interval, it's a perfect adjustment, no need to change it
      return best_interval unless must_adjust_interval?(best_interval, orientation)

      # we fit the interval in the user's occupied hours space
      user_hours = user_hours_for_adjustment(best_day, remainder_intervals, orientation)
      best_interval = [[best_interval[0], user_hours.keys.first].max,
                      [best_interval[1], user_hours.keys.last].min]

      # we adjust the best interval so that it uses half of the user to remove's hours
      adjusted_interval = ShiftScheduler::IntervalBoundariesAdjuster.build(user_hours, best_interval)

      # finally we check if the adjusted interval will leave a small hour block for the user to remove
      remainder_interval = Utils::Interval.remainder_between_intervals_compact(
        find_user_occupied_interval(@shifts[best_day], @user_to_remove),
        adjusted_interval
      )
      return adjusted_interval if remainder_interval.blank?

      # selects the second interval (the right one) as it will assume a left shift
      remainder_interval = remainder_interval[1] if remainder_interval[1].is_a?(Array)

      shift_adjusted_interval(best_day, adjusted_interval, remainder_interval, orientation)
    end

    def must_adjust_interval?(best_interval, remainder_orientation)
      %i[left right both].include?(remainder_orientation) ||
        best_interval[1] - best_interval[0] > @remaining_hours
    end

    # (This is a little hacky)
    # Sets an hour to nil in the user hours portion depending on the orientation of the remainder interval.
    # By doing this, we force an adjustment in a specific position when calling IntervalBoundariesAdjuster
    # over the best interval.
    def user_hours_for_adjustment(best_day, remainder_intervals, orientation)
      # we select the hours occupied by the user to remove
      user_hours = @shifts[best_day].dup.select { |hour, user| user == @user_to_remove.to_s && hour }

      # we mark the hour block in the opposite direction of the remainder interval
      case orientation
      when :left
        remainder_interval = remainder_intervals
        user_hours[user_hours.keys.last] = nil if Utils::Interval.length(remainder_interval) <= 2
      when :right
        remainder_interval = remainder_intervals
        user_hours[user_hours.keys.first] = nil if Utils::Interval.length(remainder_interval) <= 2
      when :both
        left_interval, right_interval = remainder_intervals
        if left_interval[1] - left_interval[0] > right_interval[1] - right_interval[0]
          user_hours[user_hours.keys.last] = nil
        else
          user_hours[user_hours.keys.first] = nil
        end
      end

      user_hours
    end

    # we make one last adjustment to the adjusted interval
    # Shifts the adjusted best interval block to the left or the right when the area covered leaves a very small
    # remaining region for the removed user.
    def shift_adjusted_interval(best_day, adjusted_best_interval, remainder_interval, orientation)
      initial_length = Utils::Interval.length(remainder_interval)
      spaces = orientation == :left ? 1 : -1
      current_hour = orientation == :left ? remainder_interval[1] : remainder_interval[0]

      while initial_length < 3 && @shifts[best_day].key?(current_hour) && @shifts[best_day][current_hour].present?
        adjusted_best_interval = Utils::Interval.shift(adjusted_best_interval, spaces)
        current_hour += spaces
        initial_length += 1
      end

      adjusted_best_interval
    end

    def find_user_occupied_interval(hours, user)
      start_hour = nil
      sorted_hours = hours.sort

      sorted_hours.each do |hour, assigned_user|
        if assigned_user.to_s == user.to_s
          start_hour = hour if start_hour.nil?
        elsif start_hour
          return [start_hour, hour - 1]
        end
      end

      # Handle case where user's hours extend to the end of the schedule
      return [start_hour, sorted_hours.last[0]] if start_hour

      nil # Return nil if no interval is found
    end

    def evaluate_interval(user_occupied_interval, candidate_interval)
      score = 1

      # Bonus for sequences that can be fully covered by available interval
      score *= 1.5 if candidate_interval[0] <= user_occupied_interval[0] &&
                      candidate_interval[1] >= user_occupied_interval[1]

      # ascending preference for longer sequences
      score *= 1.1 if Utils::Interval.length(candidate_interval) > 4
      score *= 1.1 if Utils::Interval.length(candidate_interval) > 6

      # preference when we need many hours
      score *= 1.2 if @remaining_hours > 10

      score
    end

    def multiple_user_hours?(hours)
      user_ids = hours.select { |hour| hours[hour] }.values.uniq - [nil]
      user_ids.size > 1
    end
  end
end