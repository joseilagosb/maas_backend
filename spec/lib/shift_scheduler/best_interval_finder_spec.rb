require 'rails_helper'

describe ShiftScheduler::BestIntervalFinder do
  let(:intervals) { JSON.parse(File.read('spec/fixtures/interval.json')) }

  before :each do
    @remaining_hours_by_user = { '101' => 7, '102' => 5 }
    @empty_hours = [10, 11, 12]
    @remaining_intervals = { '101' => [[10, 15]], '102' => [[11, 12]] }
  end

  context 'with valid parameters' do
    context 'find' do
      context 'single candidate interval' do
        # it's expected to select [10, 15] as it fills the most unoccupied hours
        it 'selects the correct interval' do
          expected_interval = [10, 15]

          resulting_interval, = ShiftScheduler::BestIntervalFinder.build(@remaining_hours_by_user, @empty_hours,
                                                                         @remaining_intervals)
          expect(resulting_interval).to eq(expected_interval)
        end

        it 'selects the correct user' do
          expected_user = '101'
          _, resulting_user = ShiftScheduler::BestIntervalFinder.build(@remaining_hours_by_user, @empty_hours,
                                                                       @remaining_intervals)
          expect(resulting_user).to eq(expected_user)
        end
      end

      context 'multiple candidate intervals' do
        before :each do
          @remaining_hours_by_user = { '101' => 7, '102' => 8 }
          @empty_hours = [8, 9, 10]
          @remaining_intervals = { '101' => [[8, 10], [13, 15]], '102' => [[8, 10]] }
        end

        # it has to select the user with the most remaining hours
        it 'selects the correct interval' do
          expected_interval = [8, 10]

          resulting_interval, = ShiftScheduler::BestIntervalFinder.build(@remaining_hours_by_user, @empty_hours,
                                                                         @remaining_intervals)
          expect(resulting_interval).to eq(expected_interval)
        end

        it 'selects the correct user' do
          expected_user = '102'
          _, resulting_user = ShiftScheduler::BestIntervalFinder.build(@remaining_hours_by_user, @empty_hours,
                                                                       @remaining_intervals)
          expect(resulting_user).to eq(expected_user)
        end
      end
    end
  end

  context 'with invalid parameters' do
    it 'raises an ArgumentError if remaining_hours_by_user is nil' do
      expect do
        ShiftScheduler::BestIntervalFinder.build(nil, @empty_hours, @remaining_intervals)
      end.to raise_error(ArgumentError)
    end

    it 'raises an ArgumentError if empty_hours is nil' do
      expect do
        ShiftScheduler::BestIntervalFinder.build(@remaining_hours_by_user, nil, @remaining_intervals)
      end.to raise_error(ArgumentError)
    end

    it 'raises an ArgumentError if remaining_intervals is nil' do
      expect do
        ShiftScheduler::BestIntervalFinder.build(@remaining_hours_by_user, @empty_hours, nil)
      end.to raise_error(ArgumentError)
    end
  end
end
