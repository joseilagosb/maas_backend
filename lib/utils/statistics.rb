module Utils
  module Statistics
    # Values is an array of numeric values (integers or floating point numbers)
    def self.variance(values)
      average = values.sum / values.size

      sum_of_squares = values.reduce(0) do |sum, value|
        sum + ((value - average)**2)
      end

      sum_of_squares / values.size
    end
  end
end