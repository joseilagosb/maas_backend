require 'rails_helper'

describe IntervalOccurrencesBuilder do
  let(:intervals) { JSON.parse(File.read('spec/fixtures/interval.json')) }

  before :each do
    @empty_hours = [8, 9, 10]
    @remaining_intervals = { '101' => [[8, 9]] }
  end

  describe 'with valid parameters' do
    it 'returns the correct interval occurrences' do
      expected_interval_occurrences = { 8 => { 9 => { occurrences: 2,
                                                      users: ['101'] } } }
      expected_contained_interval = [8, 9]
      resulting_interval_occurrences = IntervalOccurrencesBuilder.build(@empty_hours, @remaining_intervals)
      expect(resulting_interval_occurrences).to eq(expected_interval_occurrences)
      expect(resulting_interval_occurrences.length).to eq(1)
      expect(resulting_interval_occurrences).to have_key(expected_contained_interval[0])
      expect(resulting_interval_occurrences[expected_contained_interval[0]]).to have_key(expected_contained_interval[1])
    end

    it 'returns the correct interval occurrences for multiple users' do
      remaining_intervals_two_users = { '101' => [[8, 9]], '102' => [[8, 9]] }
      expected_contained_interval = [8, 9]
      resulting_interval_occurrences = IntervalOccurrencesBuilder.build(@empty_hours, remaining_intervals_two_users)
      expect(resulting_interval_occurrences).to have_key(expected_contained_interval[0])
      expect(resulting_interval_occurrences[expected_contained_interval[0]]).to have_key(expected_contained_interval[1])

      resulting_occurences_hash = resulting_interval_occurrences[expected_contained_interval[0]][expected_contained_interval[1]]
      expect(resulting_occurences_hash[:users].length).to eq(2)
      expect(resulting_occurences_hash[:users]).to eq(%w[101 102])
    end
  end

  describe 'with invalid parameters' do
    before :each do
      @empty_hours = [8, 9, 10]
      @remaining_intervals = { '101' => [[8, 9]], '102' => [[9, 10]] }
    end

    it 'raises an ArgumentError if empty_hours is nil' do
      expect { IntervalOccurrencesBuilder.build(nil, @remaining_intervals) }.to raise_error(ArgumentError)
    end

    it 'raises an ArgumentError if remaining_intervals is nil' do
      expect { IntervalOccurrencesBuilder.build(@empty_hours, nil) }.to raise_error(ArgumentError)
    end
  end
end
