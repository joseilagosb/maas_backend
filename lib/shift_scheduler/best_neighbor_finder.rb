# Used by the FinetuningIntervalsFinder to eliminate leftover single-hour blocks in the shifts hash

# This module's goal is to find the neighboring user whose number of hours is the highest among the users in
# the current schedule.
module ShiftScheduler
  class BestNeighborFinder
    def self.build(hours, hours_by_user, hour)
      new(hours, hours_by_user, hour).call
    end

    def initialize(hours, hours_by_user, hour)
      @hours = hours
      @hours_by_user = hours_by_user
      @hour = hour
    end

    def call
      first_candidate = @hours[@hour - 1] if @hours.key?(@hour - 1)
      second_candidate = @hours[@hour + 1] if @hours.key?(@hour + 1)

      # if both users are among the ones with the most hours, we return nil
      return nil if users_with_most_hours.include?(first_candidate) && users_with_most_hours.include?(second_candidate)

      return second_candidate if users_with_most_hours.include?(first_candidate)

      return first_candidate if users_with_most_hours.include?(second_candidate)

      # if there's only one candidate, we return it
      return sorted_candidates(first_candidate, second_candidate).first if sorted_candidates(first_candidate,
                                                                                             second_candidate).size == 1

      # we return the candidate with the fewer hours
      if sorted_candidates(first_candidate, second_candidate).first == first_candidate
        second_candidate
      elsif sorted_candidates(first_candidate, second_candidate).first == second_candidate
        first_candidate
      end
    end

    private

    def sorted_candidates(first_candidate, second_candidate)
      sorted_users = @hours_by_user.sort_by { |_, hours| hours }

      sorted_users.map do |element|
        element.first if [first_candidate, second_candidate].include?(element.first)
      end.compact
    end

    def users_with_most_hours
      max_value = @hours_by_user.values.max

      @hours_by_user.select do |_user_id, hours|
        hours == max_value
      end.keys
    end
  end
end
