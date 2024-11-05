class ShiftsFinetuningManager
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
    puts '---------------------- call ----------------------'
    selected_days = []
    selected_intervals = []
    used_days = Set.new

    # Keep finding intervals until we meet the required hours or can't find more valid intervals
    while @remaining_hours.positive?
      day, interval = find_best_interval(used_days)
      break unless day && interval

      interval_hours = interval[1] - interval[0] + 1
      @remaining_hours -= interval_hours

      selected_days << day
      selected_intervals << interval
      used_days.add(day)
    end

    [selected_days, selected_intervals]
  end

  private

  def find_best_interval(used_days)
    puts '---------- find_best_interval ------------'
    best_day = nil
    current_user_occupied_interval = nil
    best_interval = nil
    max_score = -1

    @shifts.each do |day, hours|
      next if used_days.include?(day)
      next unless @user_remaining_intervals[day]

      # we look for the hour sequences occupied by the user to remove
      user_occupied_interval = find_user_occupied_interval(hours, @user_to_remove)

      next if user_occupied_interval.nil?

      next if user_occupied_interval[1] - user_occupied_interval[0] + 1 <= 3

      @user_remaining_intervals[day].each do |available_interval|
        score = evaluate_sequence(user_occupied_interval, available_interval)

        next if multiple_user_hours?(hours) && hours.values.compact.count <= 7

        next unless score > max_score

        max_score = score
        best_day = day

        current_user_occupied_interval = user_occupied_interval

        best_interval = available_interval
      end
    end

    return [nil, nil] if best_interval.nil?

    user_hours = @shifts[best_day].dup.select do |hour, user|
      user == @user_to_remove.to_s && hour
    end

    remainder_intervals, orientation = IntervalsManager.remainder_between_intervals(current_user_occupied_interval,
                                                                                    best_interval)

    must_adjust_interval = false

    puts " user hours: #{user_hours}, best sequence: #{current_user_occupied_interval},
    best interval: #{best_interval}, remainder intervals: #{remainder_intervals}, orientation: #{orientation}"

    unless %i[equal overlap_or_adjacent].include?(orientation)
      if orientation == :left
        remainder_interval = remainder_intervals
        if remainder_interval[1] - remainder_interval[0] + 1 <= 2
          user_hours[user_hours.keys.last] = nil
          must_adjust_interval = true
        end
      elsif orientation == :right
        remainder_interval = remainder_intervals
        if remainder_interval[1] - remainder_interval[0] + 1 <= 2
          user_hours[user_hours.keys.first] = nil
          must_adjust_interval = true
        end
      elsif orientation == :both
        left_interval, right_interval = remainder_intervals
        puts 'AAAA ignore this sneaky case'
      end
    end

    if must_adjust_interval || best_interval[1] - best_interval[0] > @remaining_hours
      best_interval = [[best_interval[0], user_hours.keys.first].max,
                       [best_interval[1], user_hours.keys.last].min]

      adjusted_interval = IntervalBoundariesAdjuster.build(user_hours, best_interval)

      remainder_interval = IntervalsManager.remainder_between_intervals_compact(current_user_occupied_interval,
                                                                                adjusted_interval)

      return [best_day, adjusted_interval] if remainder_interval.blank?

      initial_length = remainder_interval[1] - remainder_interval[0] + 1

      puts "before adjusting ->> adjusted interval: #{adjusted_interval}"

      if orientation == :left
        current_hour = remainder_interval[1]
        puts "current hour: #{current_hour}, orientation: #{orientation}, initial length: #{initial_length}"
        puts "left ->> adjusted interval + 1: #{adjusted_interval[1] + 1}, best interval + 1: #{best_interval[1]}"
        while initial_length < 3 && @shifts[best_day].key?(current_hour) && @shifts[best_day][current_hour].present? &&
              adjusted_interval[1] + 1 >= best_interval[1]
          adjusted_interval = [adjusted_interval[0] + 1, adjusted_interval[1] + 1]
          current_hour += 1
          initial_length += 1
        end
      elsif orientation == :right
        current_hour = remainder_interval[0]
        puts "current hour: #{current_hour}, orientation: #{orientation}, initial length: #{initial_length}"
        puts "right ->> adjusted interval - 1: #{adjusted_interval[0] - 1}, best interval - 1: #{best_interval[0]}"
        while initial_length < 3 && @shifts[best_day].key?(current_hour) && @shifts[best_day][current_hour].present? && adjusted_interval[0] - 1 <= best_interval[0]
          adjusted_interval = [adjusted_interval[0] - 1, adjusted_interval[1] - 1]
          current_hour -= 1
          initial_length += 1
        end
      end

      puts "final remainder interval: #{remainder_interval}"

      puts "adjusted interval: #{adjusted_interval}"

      [best_day, adjusted_interval]
    else
      [best_day, best_interval]
    end
  end

  def find_user_occupied_interval(hours, user)
    start_hour = nil
    sorted_hours = hours.sort_by { |hour, _| hour }

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

  def evaluate_sequence(sequence, available_interval)
    start_hour, end_hour = sequence
    available_start, available_end = available_interval
    sequence_hours = end_hour - start_hour + 1

    # Start with base score as the length of sequence
    score = sequence_hours

    # If this sequence would exceed remaining hours needed, reduce its score
    score *= 0.5 if sequence_hours > @remaining_hours

    # Bonus for sequences that can be fully covered by available interval
    score *= 1.5 if available_start <= start_hour && available_end >= end_hour

    # Slight preference for longer sequences when we need many hours
    score *= 1.2 if @remaining_hours > 10 && sequence_hours > 4

    score
  end

  def multiple_user_hours?(hours)
    user_ids = hours.select { |hour| hours[hour] }.values.uniq - [nil]
    user_ids.size > 1
  end

  def single_user_sequence?(hours, sequence)
    start_hour, end_hour = sequence
    user_ids = (start_hour..end_hour).map { |hour| hours[hour] }.uniq - [nil]
    user_ids == [@user_to_remove.to_s]
  end
end
