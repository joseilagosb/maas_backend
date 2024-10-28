class IntervalBoundariesAdjuster
  attr_reader :hours, :number_of_occupied_hours

  def self.build(hours, number_of_occupied_hours, selected_interval)
    new(hours, number_of_occupied_hours).adjust(selected_interval)
  end

  def initialize(hours, number_of_occupied_hours)
    raise ArgumentError, 'invalid hours' unless hours.is_a?(Hash)
    raise ArgumentError, 'invalid number of occupied hours' unless number_of_occupied_hours.is_a?(Integer)

    @hours = hours
    @number_of_occupied_hours = number_of_occupied_hours
  end

  def adjust(selected_interval)
    unless selected_interval.is_a?(Array) && selected_interval.length == 2
      raise ArgumentError,
            'invalid selected interval'
    end

    left = selected_interval[0]
    right = selected_interval[1]

    adjusted_interval = selected_interval.dup

    while left <= right
      if hours[left].nil? && hours[right].nil?
        left += 1
        right -= 1
        next
      end

      number_of_nulls = hours.select { |hour, user| hour >= left && hour <= right && user.nil? }.length

      adjusted_interval = handle_boundary_adjustment(left, right, adjusted_interval, number_of_nulls)
      break
    end

    adjusted_interval
  end

  private

  def handle_boundary_adjustment(left, right, interval, number_of_nulls)
    adjusted_interval = interval.dup

    case boundary_state(left, right)
    when :both_empty
      adjusted_interval
    when :both_occupied
      adjust_both_boundaries(adjusted_interval, left, right, number_of_nulls)
    when :left_empty
      adjust_left_boundary(adjusted_interval, left, number_of_nulls)
    when :right_empty
      adjust_right_boundary(adjusted_interval, right, number_of_nulls)
    end

    adjusted_interval
  end

  def boundary_state(left, right)
    if hours[left].nil? && hours[right].nil?
      :both_empty
    elsif !hours[left].nil? && !hours[right].nil?
      :both_occupied
    elsif hours[left].nil?
      :left_empty
    else
      :right_empty
    end
  end

  def adjust_both_boundaries(interval, left, right, nulls)
    return interval if interval_too_small?(interval)

    if %i[left_to_right right_to_left].sample == :left_to_right
      adjust_left_boundary(interval, left, nulls)
    else
      adjust_right_boundary(interval, right, nulls)
    end
  end

  def adjust_left_boundary(interval, left, nulls)
    return interval if interval_too_small?(interval)

    interval[1] -= ((number_of_occupied_hours + nulls + left - interval[0]) / 2)

    interval[0] -= 1 if left - interval[0] <= 2 && interval[0] != hours.keys.first

    interval
  end

  def adjust_right_boundary(interval, right, nulls)
    return interval if interval_too_small?(interval)

    interval[0] += ((number_of_occupied_hours + nulls + interval[1] - right) / 2)

    interval[1] += 1 if right - interval[1] <= 2 && interval[1] != hours.keys.last

    interval
  end

  def interval_too_small?(interval)
    interval[1] - interval[0] < number_of_occupied_hours
  end
end
