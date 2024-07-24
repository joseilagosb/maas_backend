require 'rails_helper'

RSpec.describe ServiceWeek, type: :model do
  it 'is valid' do
    service_week = build(:service_week)
    service_week.valid?
    expect(service_week).to be_valid
  end

  it 'is invalid without a service' do
    service_week = build(:service_week, service: nil)
    service_week.valid?
    expect(service_week).to_not be_valid
  end

  context 'week validation' do
    it 'is invalid without a week' do
      service_week = build(:service_week, week: nil)
      service_week.valid?
      expect(service_week).to_not be_valid
    end

    it 'is invalid with a week out of range' do
      service_week_greater = build(:service_week, week: 54)
      service_week_greater.valid?
      expect(service_week_greater).to_not be_valid

      service_week_lower = build(:service_week, week: 0)
      service_week_lower.valid?
      expect(service_week_lower).to_not be_valid
    end

    it 'is invalid when week is already taken in service scope' do
      service = create(:service)
      service.service_weeks << build(:service_week, week: 1, service:)
      service_week_with_duplicate_week = build(:service_week, week: 1, service:)
      service.service_weeks << service_week_with_duplicate_week
      service_week_with_duplicate_week.valid?

      expect(service_week_with_duplicate_week).to_not be_valid
    end
  end

  context 'days' do
    it 'is valid with 7 elements' do
      service_week = build(:service_week)
      service_week.service_days = build_list(:service_day, 7, service_week:)
      service_week.valid?
      expect(service_week).to be_valid
    end

    it 'is invalid with more than 7 elements' do
      service_week = build(:service_week)
      service_week.service_days = build_list(:service_day, 8, service_week:)
      service_week.valid?
      expect(service_week).to_not be_valid
    end
  end
end
