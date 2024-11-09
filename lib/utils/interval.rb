module Utils
  module Interval
    def self.length(interval)
      interval.last - interval.first + 1
    end

    def self.shift(interval, spaces)
      [interval[0] + spaces, interval[1] + spaces]
    end

    def self.remainder_between_intervals(bigger_interval, smaller_interval)
      return [nil, :equal] if bigger_interval == smaller_interval
      return [bigger_interval, :separate_or_adjacent] unless overlap?(bigger_interval, smaller_interval)

      # the remainder is in the right bound of the bigger interval
      if smaller_interval[0] <= bigger_interval[0]
        [[smaller_interval[1] + 1, bigger_interval[1]], :right]
      # the remainder is in the left bound of the bigger interval
      elsif smaller_interval[1] >= bigger_interval[1]
        [[bigger_interval[0], smaller_interval[0] - 1], :left]
      else
        # the smaller interval is in the middle, so the difference are two intervals in the left and right bounds of
        # the interval
        [[[bigger_interval[0], smaller_interval[0] - 1],
          [smaller_interval[1] + 1, bigger_interval[1]]], :both]
      end
    end

    def self.remainder_between_intervals_compact(bigger_interval, smaller_interval)
      result = remainder_between_intervals(bigger_interval, smaller_interval)

      return nil if result[1] == :equal

      result[0]
    end

    def self.overlap?(interval1, interval2)
      interval1[1] >= interval2[0] && interval2[1] >= interval1[0]
    end

    def self.adjacent?(interval1, interval2)
      interval1[1] == interval2[0] - 1 || interval2[1] == interval1[0] - 1
    end

    def self.merge(interval1, interval2)
      [[interval1[0], interval2[0]].min, [interval1[1], interval2[1]].max]
    end
  end
end
