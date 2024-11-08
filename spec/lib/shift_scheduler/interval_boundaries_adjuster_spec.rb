require 'rails_helper'

describe ShiftScheduler::IntervalBoundariesAdjuster do
  context 'valid parameters' do
    context 'adjust' do
      it 'case 1' do
        @hours = { 13 => nil, 14 => '1', 15 => '1', 16 => '1', 17 => '1', 18 => '1', 19 => nil, 20 => nil }
        @selected_interval = [13, 17]

        adjusted_interval = ShiftScheduler::IntervalBoundariesAdjuster.build(@hours, @selected_interval)

        expect(adjusted_interval).to eq([13, 15])
      end

      it 'case 2' do
        @hours = { 13 => nil, 14 => nil, 15 => '3', 16 => '3', 17 => '3', 18 => '3', 19 => '3', 20 => '3' }
        @selected_interval = [14, 20]

        adjusted_interval = ShiftScheduler::IntervalBoundariesAdjuster.build(@hours, @selected_interval)

        expect(adjusted_interval).to eq([14, 16])
      end

      it 'case 3' do
        @hours = { 13 => '1', 14 => '1', 15 => '1', 16 => '1', 17 => '1', 18 => '1', 19 => '1', 20 => nil }
        @selected_interval = [16, 20]

        adjusted_interval = ShiftScheduler::IntervalBoundariesAdjuster.build(@hours, @selected_interval)
        expect(adjusted_interval).to eq([17, 20])
      end

      it 'case 4' do
        @hours = { 13 => nil, 14 => '3', 15 => '3', 16 => '3', 17 => '3', 18 => nil, 19 => nil, 20 => nil }
        @selected_interval = [13, 20]

        adjusted_interval = ShiftScheduler::IntervalBoundariesAdjuster.build(@hours, @selected_interval)

        expect(adjusted_interval).to eq([18, 20])
      end

      it 'case 5' do
        @hours = { 10 => '3', 11 => '3', 12 => '3', 13 => '3', 14 => '3', 15 => '3', 16 => nil, 17 => nil, 18 => nil,
                   19 => nil, 20 => nil }
        @selected_interval = [14, 20]

        adjusted_interval = ShiftScheduler::IntervalBoundariesAdjuster.build(@hours, @selected_interval)

        expect(adjusted_interval).to eq([16, 20])
      end

      it 'case 6' do
        @hours = { 10 => '2', 11 => '2', 12 => '2', 13 => '2', 14 => '2', 15 => '2', 16 => '2', 17 => '2', 18 => '2',
                   19 => nil, 20 => nil }
        @selected_interval = [12, 20]

        adjusted_interval = ShiftScheduler::IntervalBoundariesAdjuster.build(@hours, @selected_interval)

        expect(adjusted_interval).to eq([16, 20])
      end

      it 'case 7' do
        @hours = { 10 => '2', 11 => '2', 12 => '2', 13 => '2', 14 => '2', 15 => '2' }
        @selected_interval = [10, 15]

        adjusted_interval = ShiftScheduler::IntervalBoundariesAdjuster.build(@hours, @selected_interval)

        expect(adjusted_interval).to eq([10, 12])
      end

      # case 8: the selected interval covers the occupied region (nils left and right)
      it 'case 8' do
        @hours = { 9 => nil, 10 => nil, 11 => '2', 12 => '2', 13 => '2', 14 => nil, 15 => nil }
        @selected_interval = [9, 14]

        adjusted_interval = ShiftScheduler::IntervalBoundariesAdjuster.build(@hours, @selected_interval)

        expect(adjusted_interval).to eq([9, 11])
      end

      # case: selected interval is adjacent to the occupied region
      it 'case 9' do
        @hours = { 10 => nil, 11 => nil, 12 => nil, 13 => nil, 14 => nil, 15 => nil, 16 => nil, 17 => '1', 18 => '1',
                   19 => '1', 20 => '1' }
        @selected_interval = [11, 16]

        adjusted_interval = ShiftScheduler::IntervalBoundariesAdjuster.build(@hours, @selected_interval)

        expect(adjusted_interval).to eq([11, 16])
      end
    end
  end
end
