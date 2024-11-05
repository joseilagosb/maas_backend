# Adjusts the input interval to occupy the maximum reasonable number of hours, given the number of occupied hours
# by the user.

# To calculate that maximum number of hours, we ensure that the interval, when eventually added to the shifts hash,
# occupies the half of the already filled hours and, at the same time, fill as many empty slots as possible.

# The result of this is an interval of equal size or smaller than the input interval.

# Suppositions:
# - Hours is a hash whose values are nil or a user id. There can only be a single user in the hash.
class IntervalBoundariesAdjuster
  def self.build(hours, interval)
    new(hours, interval).adjust
  end

  def initialize(hours, interval)
    # puts "#{hours}, #{interval}"

    raise ArgumentError, 'invalid hours' unless hours.is_a?(Hash)
    raise ArgumentError, 'invalid interval' unless interval.is_a?(Array) && interval.length == 2

    @hours = hours
    @interval = interval
  end

  def adjust
    # first we detect the empty regions in the hours hash
    empty_ranges = find_empty_ranges

    # then we choose the best empty range (either at the left or right side of the interval)
    best_range = if empty_ranges.blank?
                   @interval
                 else
                   choose_best_range(empty_ranges)
                 end

    return @interval if best_range.nil?

    adjust_range(best_range)
  end

  private

  def find_empty_ranges
    ranges = []
    current_start = nil

    (@interval[0]..@interval[1]).each do |hour|
      if @hours[hour].nil?
        current_start = hour if current_start.nil?
      elsif current_start
        ranges << [current_start, hour - 1]
        current_start = nil
      end
    end

    ranges << [current_start, @interval[1]] if current_start
    ranges
  end

  # choose the largest range of nulls at either end of the interval
  # (that's the most convenient to fill)
  def choose_best_range(empty_ranges)
    ranges = empty_ranges.select do |range|
      range[0] == @interval[0] || range[1] == @interval[1]
    end

    ranges.max_by { |range| range[1] - range[0] }
  end

  # we adjust the range based on its position and the number of occupied hours
  # the resulting interval will occupy the half of the already filled hours + remaining empty slots
  def adjust_range(best_range)
    number_of_occupied_hours = @hours.values.compact.count

    # that's the expected length of the new interval. as we'll see later, it might require some adjustments
    # we establish a minimum of 3 hours just so we don't end up with a very small interval
    target_length = [(number_of_occupied_hours / 2.0).ceil, 3].max

    # puts target_length

    if best_range[0] == @interval[0]
      # if starting from the beginning, we take first half
      adjusted_end = best_range[0] + target_length - 1
      adjusted_interval = [best_range[0], adjusted_end]
      adjusted_interval = expand_interval_if_necessary(adjusted_interval, :start)
    else
      # if ending at the end, we take last half
      adjusted_start = best_range[1] - target_length + 1
      adjusted_interval = [adjusted_start, best_range[1]]
      adjusted_interval = expand_interval_if_necessary(adjusted_interval, :end)
    end

    adjusted_interval
  end

  # we check whether there are remaining null hours in what remained of the original interval
  # and if so, we expand the interval to include those null hours
  def expand_interval_if_necessary(adjusted_interval, side)
    # puts "selected interval: #{@interval}"

    # puts "discarded nulls interval: #{discarded_nulls_interval(side)}"

    remainder_interval = IntervalsManager.remainder_between_intervals_compact(
      discarded_nulls_interval(side),
      adjusted_interval
    )

    # puts "remainder interval: #{remainder_interval}"

    remaining_nulls = if remainder_interval.blank?
                        0
                      else
                        @hours.select do |hour, user|
                          hour >= remainder_interval[0] && hour <= remainder_interval[1] && user.nil?
                        end.length
                      end

    # puts "adjusted interval: #{adjusted_interval}, remaining nulls: #{remaining_nulls}"

    if side == :start
      adjusted_interval[1] += remaining_nulls
    else
      adjusted_interval[0] -= remaining_nulls
    end

    adjusted_interval
  end

  # discards leading or trailing nulls from an interval
  def discarded_nulls_interval(side)
    resulting_interval = @interval.dup

    if side == :start
      resulting_interval[1] = (@interval[0]..@interval[1]).reverse_each.find { |hour| @hours[hour].present? }
      resulting_interval[1] = @interval[1] if resulting_interval[1].nil?
    else
      resulting_interval[0] = (@interval[0]..@interval[1]).find { |hour| @hours[hour].present? }
      resulting_interval[0] = @interval[0] if resulting_interval[0].nil?
    end
    resulting_interval
  end
end
