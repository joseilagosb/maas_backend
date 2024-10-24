require 'rails_helper'

describe AvailableIntervalsManager do
  let(:availabilities) do
    JSON.parse(File.read('spec/fixtures/availability.json'))
  end
  let(:expected_intervals) { JSON.parse(File.read('spec/fixtures/interval.json')) }

  context 'with valid parameters' do
    # Represents a monday to tuesday availability, with the availability of two users of ids 101 and 102
    # Both users are available everyday albeit in different time slots
    context 'base availability' do
      let(:intervals) { AvailableIntervalsManager.build(availabilities['base']) }

      it 'returns the correct number of days' do
        puts intervals
        expect(intervals.length).to eq(2)
      end

      it 'returns the correct number of users for each day' do
        intervals.each_value do |day|
          expect(day.length).to eq(2)
        end
      end

      it 'returns the correct number of intervals for each user' do
        intervals.each_value do |day|
          day.each_value do |interval|
            expect(interval.length).to eq(1)
          end
        end
      end

      it 'returns the correct intervals for each user in each day' do
        expected_intervals_monday = { '101' => [[8, 9]], '102' => [[9, 10]] }
        intervals['1'].each do |user, interval|
          expect(interval).to eq(expected_intervals_monday[user])
        end
        expected_intervals_tuesday = { '101' => [[8, 8]], '102' => [[8, 10]] }
        intervals['2'].each do |user, interval|
          expect(interval).to eq(expected_intervals_tuesday[user])
        end
      end

      it 'returns the expected intervals hash' do
        expect(intervals).to eq(expected_intervals['base'])
      end
    end

    context 'with two intervals in a day' do
      let(:intervals_with_two_intervals_in_a_day) do
        AvailableIntervalsManager.build(availabilities['with_two_intervals_in_a_day'])
      end

      it 'returns two intervals in a single day' do
        intervals_with_two_intervals_in_a_day['1'].each_value do |interval|
          expect(interval.length).to eq(2)
        end
      end

      it 'returns the expected intervals hash' do
        expect(intervals_with_two_intervals_in_a_day).to eq(expected_intervals['with_two_intervals_in_a_day'])
      end
    end

    context 'with unavailable user in a day' do
      let(:intervals_with_unavailable_user) do
        AvailableIntervalsManager.build(availabilities['with_unavailable_user'])
      end

      before :each do
        @monday_intervals = intervals_with_unavailable_user['1']
        @tuesday_intervals = intervals_with_unavailable_user['2']
      end

      it 'returns the correct number of intervals for each user' do
        expect(@monday_intervals.length).to eq(1)
        expect(@tuesday_intervals.length).to eq(2)
      end

      it 'does not contain user with unavailable hours' do
        expect(@monday_intervals).not_to include('101')
        expect(@tuesday_intervals).to include('101')
      end

      it 'returns the expected intervals hash' do
        expect(intervals_with_unavailable_user).to eq(expected_intervals['with_unavailable_user'])
      end
    end

    context 'empty availability' do
      let(:intervals_with_empty_availability) do
        AvailableIntervalsManager.build(availabilities['empty'])
      end

      it 'returns an empty hash for each day' do
        intervals_with_empty_availability.each_value do |day|
          expect(day).to eq({})
        end
      end

      it 'returns the expected intervals hash' do
        expect(intervals_with_empty_availability).to eq(expected_intervals['empty'])
      end
    end
  end

  context 'with invalid parameters' do
    it 'raises an ArgumentError' do
      expect { AvailableIntervalsManager.build(nil) }.to raise_error(ArgumentError)
    end
  end
end
