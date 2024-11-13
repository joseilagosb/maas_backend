require 'rails_helper'

describe ShiftScheduler::BestNeighborFinder do
  context 'valid parameters' do
    context 'call' do
      # has a valid user and a nil as neighbors
      context 'single neighbor' do
        let(:hours) { { 17 => '1', 18 => '1', 19 => '1', 20 => '1', 21 => '2', 22 => nil } }
        let(:target_hour) { 21 }

        it 'returns the only neighbor if it has the fewest hours' do
          hours_by_user = { '1' => 4, '2' => 5 }
          expect(ShiftScheduler::BestNeighborFinder.build(hours, hours_by_user, target_hour)).to eq('1')
        end

        it 'returns nil if it has the most hours' do
          hours_by_user = { '1' => 5, '2' => 4 }
          expect(ShiftScheduler::BestNeighborFinder.build(hours, hours_by_user, target_hour)).to be_nil
        end
      end

      # has two valid users as neighbors, therefore it has to choose the best one
      context 'two neighbors' do
        let(:hours) { { 17 => '1', 18 => '1', 19 => '1', 20 => '3', 21 => '2', 22 => '2' } }
        let(:target_hour) { 20 }

        it 'returns the left neighbor if right has more hours' do
          hours_by_user = { '1' => 4, '2' => 2, '3' => 6 }
          expect(ShiftScheduler::BestNeighborFinder.build(hours, hours_by_user, target_hour)).to eq('1')
        end

        it 'returns the right neighbor if it has fewer hours' do
          hours_by_user = { '1' => 6, '2' => 2, '3' => 4 }
          expect(ShiftScheduler::BestNeighborFinder.build(hours, hours_by_user, target_hour)).to eq('2')
        end

        it 'returns nil if both have the same (and highest) hours' do
          hours_by_user = { '1' => 5, '2' => 5, '3' => 3 }
          expect(ShiftScheduler::BestNeighborFinder.build(hours, hours_by_user, target_hour)).to be_nil
        end
      end
    end
  end
end
