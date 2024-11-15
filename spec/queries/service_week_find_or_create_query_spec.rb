require 'rails_helper'

describe ServiceWeekFindOrCreateQuery do
  before do
    @service = create(:service_with_weeks_and_working_days)
  end

  context 'with valid options' do
    let(:week) { 10 }
    let(:service_id) { @service.id }

    let(:service_week) { ServiceWeekFindOrCreateQuery.new(options: { service_id:, week: }).call }

    it 'creates a service week if it does not exist' do
      expect(service_week).to be_present
    end

    it 'returns the correct service week' do
      expect(service_week.week).to eq(week)
      expect(service_week.service_id).to eq(service_id)
    end

    it 'creates the respective service days' do
      expect(service_week.service_days).to be_present
      expect(service_week.service_days.size).to eq(7)
    end

    it 'creates the respective service hours' do
      service_week.service_days.each do |service_day|
        expect(service_day.service_hours).to be_present
        expect(service_day.service_hours.size).to eq(7)
      end
    end
  end

  context 'with invalid options' do
    let(:week) { 28 }
    let(:service_id) { @service.id }

    it 'raises an error if the week is nil' do
      expect do
        ServiceWeekFindOrCreateQuery.new(options: { service_id:, week: nil })
      end.to raise_error(ArgumentError)
    end

    it 'raises an error if the service id is nil' do
      expect do
        ServiceWeekFindOrCreateQuery.new(options: { service_id: nil, week: })
      end.to raise_error(ArgumentError)
    end
  end
end
