require 'rails_helper'

describe Utils::Interval do
  context 'shift' do
    let(:interval) { [1, 3] }

    it 'shifts the interval to the right if the spaces are positive' do
      expect(Utils::Interval.shift(interval, 2)).to eq([3, 5])
    end

    it 'shifts the interval to the left if the spaces are negative' do
      expect(Utils::Interval.shift(interval, -2)).to eq([-1, 1])
    end

    it 'returns the same interval if the spaces are 0' do
      expect(Utils::Interval.shift(interval, 0)).to eq(interval)
    end
  end

  context 'remainder between intervals' do
    let(:bigger_interval) { [1, 6] }

    it 'returns left side remainder if the smaller interval is in the right bound' do
      right_bound_interval = [4, 6]

      remainder, side = Utils::Interval.remainder_between_intervals(bigger_interval, right_bound_interval)
      expect(remainder).to eq([1, 3])
      expect(side).to eq(:left)
    end

    it 'returns right side remainder if the smaller interval is in the left bound' do
      left_bound_interval = [0, 2]

      remainder, side = Utils::Interval.remainder_between_intervals(bigger_interval, left_bound_interval)
      expect(remainder).to eq([3, 6])
      expect(side).to eq(:right)
    end

    it 'returns nil if intervals are equal' do
      remainder, side = Utils::Interval.remainder_between_intervals(bigger_interval, bigger_interval)
      expect(remainder).to eq(nil)
      expect(side).to eq(:equal)
    end

    it 'returns the same interval if intervals are separate' do
      separate_interval = [9, 10]

      remainder, side = Utils::Interval.remainder_between_intervals(bigger_interval, separate_interval)
      expect(remainder).to eq(bigger_interval)
      expect(side).to eq(:separate_or_adjacent)
    end

    it 'returns the same interval if intervals are adjacent' do
      adjacent_interval = [7, 8]

      remainder, side = Utils::Interval.remainder_between_intervals(bigger_interval, adjacent_interval)
      expect(remainder).to eq(bigger_interval)
      expect(side).to eq(:separate_or_adjacent)
    end
  end

  context 'overlap' do
    it 'returns true if intervals overlap' do
      expect(Utils::Interval.overlap?([1, 3], [2, 4])).to eq(true)
    end

    it 'returns true if intervals are equal' do
      expect(Utils::Interval.overlap?([1, 3], [1, 3])).to eq(true)
    end

    it 'returns false if intervals do not overlap' do
      expect(Utils::Interval.overlap?([1, 3], [5, 6])).to eq(false)
    end

    it 'returns false if intervals are adjacent' do
      expect(Utils::Interval.overlap?([1, 3], [4, 5])).to eq(false)
    end
  end

  context 'adjacent' do
    it 'returns true if intervals are adjacent' do
      expect(Utils::Interval.adjacent?([1, 3], [4, 6])).to eq(true)
    end

    it 'returns false if intervals are not adjacent' do
      expect(Utils::Interval.adjacent?([1, 3], [6, 6])).to eq(false)
    end

    it 'returns false if intervals are equal' do
      expect(Utils::Interval.adjacent?([1, 3], [1, 3])).to eq(false)
    end

    it 'returns false if intervals overlap' do
      expect(Utils::Interval.adjacent?([1, 3], [2, 4])).to eq(false)
    end
  end

  context 'merge' do
    it 'merges two intervals' do
      expect(Utils::Interval.merge([1, 3], [4, 6])).to eq([1, 6])
    end

    it 'returns the same interval if intervals are equal' do
      expect(Utils::Interval.merge([1, 3], [1, 3])).to eq([1, 3])
    end
  end
end
