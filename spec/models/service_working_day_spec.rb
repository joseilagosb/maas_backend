require 'rails_helper'

RSpec.describe ServiceWorkingDay, type: :model do
  it 'is valid' do
    service_working_day = build(:service_working_day)
    service_working_day.valid?
    expect(service_working_day).to be_valid
  end

  context 'day validation' do
    it 'is invalid without a day' do
      service_working_day = build(:service_working_day, day: nil)
      service_working_day.valid?
      expect(service_working_day).to_not be_valid
    end

    it 'is invalid with a day out of range' do
      service_working_day_greater = build(:service_working_day, day: 8)
      service_working_day_greater.valid?
      expect(service_working_day_greater).to_not be_valid

      service_working_day_lower = build(:service_working_day, day: 0)
      service_working_day_lower.valid?
      expect(service_working_day_lower).to_not be_valid
    end

    it 'is invalid when day is already taken in service scope' do
      service = create(:service)
      service.service_working_days << build(:service_working_day, day: 1, service:)
      working_day_with_duplicate_day = build(:service_working_day, day: 1, service:)
      service.service_working_days << working_day_with_duplicate_day
      working_day_with_duplicate_day.valid?

      expect(working_day_with_duplicate_day).to_not be_valid
    end
  end

  context 'from validation' do
    it 'is invalid without a from' do
      service_working_day = build(:service_working_day, from: nil)
      service_working_day.valid?
      expect(service_working_day).to_not be_valid
    end

    it 'is invalid with a from out of range' do
      working_day_greater = build(:service_working_day, from: 24)
      working_day_greater.valid?
      expect(working_day_greater).to_not be_valid

      working_day_lower = build(:service_working_day, from: -1)
      working_day_lower.valid?
      expect(working_day_lower).to_not be_valid
    end
  end

  context 'to validation' do
    it 'is invalid without a to' do
      service_working_day = build(:service_working_day, to: nil)
      service_working_day.valid?
      expect(service_working_day).to_not be_valid
    end
  
    it 'is invalid with a to out of range' do
      working_day_greater = build(:service_working_day, to: 24)
      working_day_greater.valid?
      expect(working_day_greater).to_not be_valid
  
      working_day_lower = build(:service_working_day, to: -1)
      working_day_lower.valid?
      expect(working_day_lower).to_not be_valid
    end
  
    it 'is invalid with a to less than from' do
      service_working_day = build(:service_working_day, from: 10, to: 9)
      service_working_day.valid?
      expect(service_working_day).to_not be_valid
    end
  end
end
