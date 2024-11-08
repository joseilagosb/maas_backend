# Finds the interval with the most registered occurences for the given day, and chooses the user with the least
# hours assigned in the shifts hash at the time of the call
module ShiftScheduler
  class BestIntervalFinder
    def self.build(remaining_hours_by_user, empty_hours, remaining_intervals)
      new(remaining_hours_by_user, empty_hours, remaining_intervals).call
    end

    def initialize(remaining_hours_by_user, empty_hours, remaining_intervals)
      raise ArgumentError, 'invalid remaining hours by user' unless remaining_hours_by_user.is_a?(Hash)
      raise ArgumentError, 'invalid empty hours' unless empty_hours.is_a?(Array)
      raise ArgumentError, 'invalid remaining intervals' unless remaining_intervals.is_a?(Hash)

      @remaining_hours_by_user = remaining_hours_by_user
      @empty_hours = empty_hours
      @remaining_intervals = remaining_intervals
    end

    def call
      return nil if @empty_hours.empty?
      return nil if @remaining_intervals.empty?

      interval_occurrences = ShiftScheduler::IntervalOccurrencesBuilder.build(@empty_hours, @remaining_intervals)
      find_best_interval_and_user(interval_occurrences)
    end

    private

    # we traverse the interval occurrences hash and find the interval and user with the most registered
    # occurences for the given day
    def find_best_interval_and_user(interval_occurrences)
      selected_interval = nil
      selected_user = nil
      max_occurrences = 0

      interval_occurrences.each do |start_interval, end_intervals|
        end_intervals.each do |end_interval, details|
          next unless details[:occurrences] > max_occurrences

          max_occurrences = details[:occurrences]
          selected_interval = [start_interval, end_interval]

          # if there are multiple candidate users, we select the one with the most remaining hours
          selected_user = details[:users].max_by { |user_id| @remaining_hours_by_user[user_id] }
        end
      end

      [selected_interval, selected_user]
    end
  end
end
