require 'rails_helper'

RSpec.describe ServiceDay, type: :model do
  it 'is valid' do
    service_day = build(:service_day)
    service_day.valid?
    expect(service_day).to be_valid
  end

  context 'hours validation' do
    it 'is valid with 24 elements' do
      service_day = build(:service_day)
      service_day.service_hours = build_list(:service_hour, 24, service_day:)
      service_day.valid?
      expect(service_day).to be_valid
    end

    it 'is invalid with more than 24 elements' do
      service_day = build(:service_day)
      service_day.service_hours = build_list(:service_hour, 25, service_day:)
      service_day.valid?
      expect(service_day).to_not be_valid
    end
  end

  context 'day validation' do
    it 'is invalid without a day' do
      service_day = build(:service_day, day: nil)
      service_day.valid?
      expect(service_day).to_not be_valid
    end

    it 'is invalid with a day out of range' do
      service_day_greater = build(:service_day, day: 8)
      service_day_greater.valid?
      expect(service_day_greater).to_not be_valid

      service_day_lower = build(:service_day, day: 0)
      service_day_lower.valid?
      expect(service_day_lower).to_not be_valid
    end

    it 'is invalid when day is already taken in service week scope' do
      service_week = create(:service_week)
      service_week.service_days << build(:service_day, day: 1, service_week:)
      service_day_with_duplicate_day = build(:service_day, day: 1, service_week:)
      service_week.service_days << service_day_with_duplicate_day
      service_day_with_duplicate_day.valid?

      expect(service_day_with_duplicate_day).to_not be_valid
    end
  end
end
