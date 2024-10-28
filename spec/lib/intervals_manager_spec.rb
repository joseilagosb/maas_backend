require 'rails_helper'

describe IntervalsManager do
  let(:intervals) { JSON.parse(File.read('spec/fixtures/interval.json')) }

  context 'with valid parameters' do
    context 'pop interval' do
      before :each do
        @day = '1'
        @user_id = '101'
        # day '1' user_id '101' has two intervals
        @intervals = intervals['with_two_intervals_in_a_day'].dup
      end

      it 'removes the interval' do
        expect(@intervals[@day][@user_id].length).to eq(2)
        IntervalsManager.pop_interval(@intervals, @day, @user_id)
        expect(@intervals[@day][@user_id].length).to eq(1)
      end

      it 'returns the last interval' do
        expected_interval = @intervals[@day][@user_id].last

        expect(IntervalsManager.pop_interval(@intervals, @day, @user_id)).to eq(expected_interval)
      end

      it 'returns nil if user is not found' do
        @user_id_not_present = '103'

        expect(IntervalsManager.pop_interval(@intervals, @day, @user_id_not_present)).to be_nil
      end

      it 'returns nil if day is not found' do
        @day_not_present = '3'

        expect(IntervalsManager.pop_interval(@intervals, @day_not_present, @user_id)).to be_nil
      end

      it 'deletes the user if no intervals are left' do
        # day '1' user_id '101' has one interval
        intervals_with_a_single_interval = intervals['base']

        IntervalsManager.pop_interval(intervals_with_a_single_interval, @day, @user_id)
        expect(intervals_with_a_single_interval[@day][@user_id]).to be_nil
      end
    end

    context 'remove interval' do
      before :each do
        @day = '1'
        @user_id = '101'
        # day '1' user_id '101' has two intervals
        @intervals = intervals['with_two_intervals_in_a_day'].dup
        @interval_to_remove = intervals['with_two_intervals_in_a_day'][@day][@user_id].first
      end

      it 'removes the interval' do
        expect(@intervals[@day][@user_id].length).to eq(2)
        IntervalsManager.remove_interval(@intervals, @day, @user_id, @interval_to_remove)
        expect(@intervals[@day][@user_id].length).to eq(1)
      end

      it 'returns the removed interval' do
        expect(IntervalsManager.remove_interval(@intervals, @day, @user_id, @interval_to_remove)).to eq(@interval_to_remove)
      end

      it 'deletes the user if no intervals are left' do
        # day '1' user_id '101' has one interval
        intervals_with_a_single_interval = intervals['base']

        IntervalsManager.remove_interval(intervals_with_a_single_interval, @day, @user_id, @interval_to_remove)
        expect(intervals_with_a_single_interval[@day][@user_id]).to be_nil
      end
    end

    context 'add interval' do
      before :each do
        @day = '1'
        @user_id = '101'
        # day '1' user_id '101' has two intervals
        @intervals = intervals['with_two_intervals_in_a_day'].dup
      end

      it 'is added' do
        separate_interval = [16, 17]

        expect(@intervals[@day][@user_id].length).to eq(2)
        IntervalsManager.add_interval(@intervals, @day, @user_id, separate_interval)
        expect(@intervals[@day][@user_id].length).to eq(3)
      end

      it 'merges the interval if it overlaps with an existing one' do
        overlapping_interval = [9, 10]

        expect(@intervals[@day][@user_id].length).to eq(2)

        IntervalsManager.add_interval(@intervals, @day, @user_id, overlapping_interval)

        expected_merged_interval = [8, 10]
        expect(@intervals[@day][@user_id].length).to eq(2)
        expect(@intervals[@day][@user_id].min_by(&:first)).to eq(expected_merged_interval)
      end

      it 'merges the interval if it is adjacent to an existing one' do
        adjacent_interval = [13, 15]

        expect(@intervals[@day][@user_id].length).to eq(2)

        IntervalsManager.add_interval(@intervals, @day, @user_id, adjacent_interval)

        expected_merged_interval = [12, 15]
        expect(@intervals[@day][@user_id].length).to eq(2)
        expect(@intervals[@day][@user_id].max_by(&:first)).to eq(expected_merged_interval)
      end
    end
  end
end
