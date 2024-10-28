class IntervalOccurrencesBuilder
  attr_reader :empty_hours, :remaining_intervals

  def self.build(empty_hours, remaining_intervals)
    puts 'empty hours', empty_hours
    puts 'remaining intervals', remaining_intervals
    new(empty_hours, remaining_intervals).call
  end

  def initialize(empty_hours, remaining_intervals)
    raise ArgumentError, 'invalid empty hours' unless empty_hours.is_a?(Array)

    raise ArgumentError, 'invalid remaining intervals' unless remaining_intervals.is_a?(Hash)

    @empty_hours = empty_hours
    @remaining_intervals = remaining_intervals
  end

  def call
    interval_occurrences = {}

    # First we find the interval(s) that can fit the best given the empty hours in the day
    empty_hours.each do |element|
      remaining_intervals.each do |user_id, intervals|
        next if intervals.blank?

        process_user_intervals(user_id, element, intervals, interval_occurrences)
      end
    end

    interval_occurrences
  end

  private

  def process_user_intervals(user_id, element, intervals, interval_occurrences)
    intervals.each do |interval|
      next unless element >= interval[0] && element <= interval[1]

      interval_occurrences[interval[0]] = {} if interval_occurrences[interval[0]].nil?

      if interval_occurrences[interval[0]][interval[1]].nil?
        interval_occurrences[interval[0]][interval[1]] =
          { occurrences: 0, users: [] }
      end

      interval_occurrences[interval[0]][interval[1]][:occurrences] += 1
      unless interval_occurrences[interval[0]][interval[1]][:users].include?(user_id)
        interval_occurrences[interval[0]][interval[1]][:users] << user_id
      end
    end
  end
end