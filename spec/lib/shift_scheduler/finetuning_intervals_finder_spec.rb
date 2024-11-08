require 'rails_helper'

describe ShiftScheduler::FinetuningIntervalsFinder do
  context 'valid parameters' do
    context 'call' do
      it 'case 1' do
        @shifts = {
          1 => { 13 => nil, 14 => '3', 15 => '3', 16 => '3', 17 => '2', 18 => '2', 19 => '2', 20 => '2' },
          2 => { 13 => '2', 14 => '2', 15 => '2', 16 => '2', 17 => '3', 18 => '3', 19 => '3', 20 => nil },
          3 => { 13 => nil, 14 => '2', 15 => '2', 16 => '2', 17 => '2', 18 => '2', 19 => '2', 20 => '2' },
          4 => { 13 => '3', 14 => '3', 15 => '3', 16 => '3', 17 => '3', 18 => '2', 19 => '2', 20 => '2' },
          5 => { 13 => nil, 14 => '3', 15 => '3', 16 => '3', 17 => '3', 18 => '2', 19 => '2', 20 => '2' },
          6 => { 10 => '2', 11 => '2', 12 => '2', 13 => '2', 14 => '2', 15 => '1', 16 => '1', 17 => '1', 18 => '1',
                 19 => '1', 20 => '1' },
          7 => { 10 => '2', 11 => '2', 12 => '2', 13 => '2', 14 => '1', 15 => '1', 16 => '1', 17 => '1', 18 => '1',
                 19 => '1', 20 => '1' }
        }
        @user_remaining_intervals = { 1 => [[17, 19]], 2 => [[13, 18]], 3 => [[14, 20]], 4 => [[14, 19]], 5 => [[15, 18]],
                                      6 => [[12, 14]] }
        @user_to_add = 3
        @user_to_remove = 2
        @required_hours_to_remove = 7

        resulting_days, resulting_intervals = ShiftScheduler::FinetuningIntervalsFinder.build(
          @shifts, @user_remaining_intervals, @user_to_add, @user_to_remove, @required_hours_to_remove
        )

        expect(resulting_days).to eq([3])
        expect(resulting_intervals).to eq([[14, 20]])
      end

      it 'case 2' do
        @shifts = { 1 => { 13 => nil, 14 => '3', 15 => '3', 16 => '3', 17 => '2', 18 => '2', 19 => '2', 20 => '2' },
                    2 => { 13 => '1', 14 => '1', 15 => '1', 16 => '3', 17 => '3', 18 => '3', 19 => '3', 20 => nil },
                    3 => { 13 => nil, 14 => '1', 15 => '1', 16 => '1', 17 => '1', 18 => '1', 19 => '1', 20 => '1' },
                    4 => { 13 => '3', 14 => '3', 15 => '3', 16 => '1', 17 => '1', 18 => '1', 19 => '1', 20 => nil },
                    5 => { 13 => nil, 14 => '2', 15 => '2', 16 => '2', 17 => '2', 18 => '2', 19 => '2', 20 => '2' },
                    6 => { 10 => '2', 11 => '2', 12 => '2', 13 => '2', 14 => '2', 15 => '2', 16 => '1', 17 => '1',
                           18 => '1', 19 => '1', 20 => '1' },
                    7 => { 10 => '3', 11 => '3', 12 => '3', 13 => '3', 14 => '3', 15 => '3', 16 => '1', 17 => '1',
                           18 => '1', 19 => '1', 20 => '1' } }
        @user_remaining_intervals = { 1 => [[17, 17]], 2 => [[15, 15]], 3 => [[15, 20]], 4 => [[16, 18]], 5 => [[14, 18]],
                                      6 => [[14, 19]] }
        @user_to_add = 2
        @user_to_remove = 1
        @required_hours_to_remove = 8

        resulting_days, resulting_intervals = ShiftScheduler::FinetuningIntervalsFinder.build(
          @shifts, @user_remaining_intervals, @user_to_add, @user_to_remove, @required_hours_to_remove
        )

        expect(resulting_days).to eq([3, 6])
        expect(resulting_intervals).to eq([[18, 20], [15, 17]])
      end

      it 'case 3' do
        @shifts = {
          1 => { 17 => '1', 18 => '1', 19 => '1', 20 => '2', 21 => '2', 22 => nil },
          2 => { 17 => nil, 18 => '2', 19 => '2', 20 => '1', 21 => '1', 22 => '1' },
          3 => { 17 => '1', 18 => '1', 19 => '1', 20 => '2', 21 => '2', 22 => '2' },
          4 => { 17 => nil, 18 => '2', 19 => '2', 20 => '1', 21 => '1', 22 => '1' },
          5 => { 17 => '1', 18 => '1', 19 => '3', 20 => '3', 21 => '3', 22 => nil },
          6 => { 12 => nil, 13 => nil, 14 => '1', 15 => '1', 16 => '1', 17 => '1', 18 => '1', 19 => '1',
                 20 => '1', 21 => '1', 22 => nil, 23 => nil },
          7 => { 12 => '3', 13 => '3', 14 => '3', 15 => '3', 16 => '3', 17 => '3', 18 => '3', 19 => '3',
                 20 => '3', 21 => '3', 22 => '3', 23 => nil }
        }
        @user_remaining_intervals = { 1 => [[18, 19]], 2 => [[20, 21]], 4 => [[20, 20]], 6 => [[14, 19]],
                                      7 => [[13, 22]] }
        @user_to_add = 2
        @user_to_remove = 1
        @required_hours_to_remove = 4

        resulting_days, resulting_intervals = ShiftScheduler::FinetuningIntervalsFinder.build(
          @shifts, @user_remaining_intervals, @user_to_add, @user_to_remove, @required_hours_to_remove
        )

        expect(resulting_days).to eq([6])
        expect(resulting_intervals).to eq([[14, 17]])
      end

      it 'case 4' do
        @shifts = {
          1 => { 17 => '1', 18 => '1', 19 => '2', 20 => '2', 21 => '2', 22 => nil },
          2 => { 17 => nil, 18 => '1', 19 => '1', 20 => '1', 21 => '1', 22 => '1' },
          3 => { 17 => '1', 18 => '1', 19 => '1', 20 => '2', 21 => '2', 22 => '2' },
          4 => { 17 => nil, 18 => '2', 19 => '2', 20 => '1', 21 => '1', 22 => '1' },
          5 => { 17 => '1', 18 => '1', 19 => '1', 20 => '3', 21 => '3', 22 => nil },
          6 => { 12 => nil, 13 => nil, 14 => '1', 15 => '1', 16 => '1', 17 => '1', 18 => '3',
                 19 => '3', 20 => '3', 21 => '3', 22 => nil, 23 => nil },
          7 => { 12 => '3', 13 => '3', 14 => '3', 15 => '3', 16 => '3', 17 => '2', 18 => '2',
                 19 => '2', 20 => '2', 21 => '2', 22 => '2', 23 => nil }
        }
        @user_remaining_intervals = { 1 => [[19, 21]], 3 => [[17, 20]], 4 => [[19, 21]], 5 => [[18, 19]],
                                      6 => [[15, 17]], 7 => [[17, 22]] }
        @user_to_add = 3
        @user_to_remove = 1
        @required_hours_to_remove = 2

        resulting_days, resulting_intervals = ShiftScheduler::FinetuningIntervalsFinder.build(
          @shifts, @user_remaining_intervals, @user_to_add, @user_to_remove, @required_hours_to_remove
        )

        expect(resulting_days).to eq([6])
        expect(resulting_intervals).to eq([[17, 19]])
      end

      it 'case 5' do
        @shifts = {
          1 => { 13 => '3', 14 => '3', 15 => '3', 16 => '3', 17 => '2', 18 => '2', 19 => '2', 20 => nil },
          2 => { 13 => '1', 14 => '1', 15 => '1', 16 => '2', 17 => '2', 18 => '2', 19 => '2', 20 => nil },
          3 => { 13 => '1', 14 => '1', 15 => '1', 16 => '1', 17 => '3', 18 => '3', 19 => '3', 20 => '3' },
          4 => { 13 => '2', 14 => '2', 15 => '2', 16 => '1', 17 => '1', 18 => '1', 19 => nil, 20 => nil },
          5 => { 13 => '1', 14 => '1', 15 => '1', 16 => '1', 17 => '1', 18 => '1', 19 => '1', 20 => '1' },
          6 => { 10 => nil, 11 => nil, 12 => '3', 13 => '3', 14 => '3', 15 => '3', 16 => '3', 17 => '1', 18 => '1',
                 19 => '1', 20 => '1' },
          7 => { 10 => nil, 11 => '2', 12 => '2', 13 => '2', 14 => '2', 15 => '2', 16 => '2', 17 => '1', 18 => '1',
                 19 => '1', 20 => '1' }
        }
        @user_remaining_intervals = { 1 => [[17, 18]], 2 => [[15, 20]], 3 => [[14, 16]], 4 => [[15, 19]], 5 => [[13, 18]],
                                      7 => [[12, 18]] }
        @user_to_add = 3
        @user_to_remove = 1
        @required_hours_to_remove = 6

        resulting_days, resulting_intervals = ShiftScheduler::FinetuningIntervalsFinder.build(
          @shifts, @user_remaining_intervals, @user_to_add, @user_to_remove, @required_hours_to_remove
        )

        expect(resulting_days).to eq([7, 5])
        expect(resulting_intervals).to eq([[15, 17], [13, 16]])
      end

      # case: there are two remaining spaces between the user occupied hours and the best interval
      it 'case 6' do
        @shifts = {
          1 => { 13 => '3', 14 => '3', 15 => '3', 16 => '3', 17 => '2', 18 => '2', 19 => '2', 20 => nil },
          2 => { 13 => '1', 14 => '1', 15 => '1', 16 => '1', 17 => '1', 18 => '1', 19 => '1', 20 => '1' },
          3 => { 13 => '2', 14 => '2', 15 => '2', 16 => '2', 17 => '2', 18 => '2', 19 => '2', 20 => '2' },
          4 => { 13 => '2', 14 => '2', 15 => '2', 16 => '3', 17 => '3', 18 => '3', 19 => '3', 20 => nil },
          5 => { 13 => '1', 14 => '1', 15 => '1', 16 => '1', 17 => '1', 18 => '1', 19 => '1', 20 => '1' },
          6 => { 10 => nil, 11 => nil, 12 => '3', 13 => '3', 14 => '3', 15 => '3', 16 => '3', 17 => '1', 18 => '1',
                 19 => '1', 20 => '1' },
          7 => { 10 => '1', 11 => '1', 12 => '1', 13 => '1', 14 => '3', 15 => '3', 16 => '3', 17 => '3', 18 => '3',
                 19 => nil, 20 => nil }
        }
        @user_remaining_intervals = { 2 => [[14, 19]], 4 => [[16, 19]], 5 => [[15, 19]], 7 => [[11, 16]] }
        @user_to_add = 2
        @user_to_remove = 1
        @required_hours_to_remove = 4

        resulting_days, resulting_intervals = ShiftScheduler::FinetuningIntervalsFinder.build(
          @shifts, @user_remaining_intervals, @user_to_add, @user_to_remove, @required_hours_to_remove
        )

        expect(resulting_days).to eq([2])
        expect(resulting_intervals).to eq([[14, 17]])
      end
    end
  end
end
