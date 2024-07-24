require 'rails_helper'

RSpec.describe ServiceHour, type: :model do
  it 'is valid' do
    service_hour = build(:service_hour)
    service_hour.valid?
    expect(service_hour).to be_valid
  end

  context 'hour validation' do
    it 'is invalid without a hour' do
      service_hour = build(:service_hour, hour: nil)
      service_hour.valid?
      expect(service_hour).to_not be_valid
    end

    it 'is invalid with a hour out of range' do
      service_hour_greater = build(:service_hour, hour: 24)
      service_hour_greater.valid?
      expect(service_hour_greater).to_not be_valid

      service_hour_lower = build(:service_hour, hour: -1)
      service_hour_lower.valid?
      expect(service_hour_lower).to_not be_valid
    end

    it 'is invalid when hour is already taken in service day scope' do
      service_day = create(:service_day)
      service_day.service_hours << build(:service_hour, hour: 0, service_day:)
      service_hour_with_duplicate_hour = build(:service_hour, hour: 0, service_day:)
      service_day.service_hours << service_hour_with_duplicate_hour
      service_hour_with_duplicate_hour.valid?

      expect(service_hour_with_duplicate_hour).to_not be_valid
    end
  end
end
