require 'rails_helper'

RSpec.describe Service, type: :model do
  it 'is valid' do
    service = build(:service)
    service.valid?
    expect(service).to be_valid
  end

  it 'is invalid without a name' do
    service = build(:service, name: nil)
    service.valid?
    expect(service).not_to be_valid
  end

  it 'is invalid when name is already taken' do
    service = create(:service)
    duplicate_service = build(:service, name: service.name)
    duplicate_service.valid?
    expect(duplicate_service).not_to be_valid
  end

  it 'defaults active to true' do
    service = build(:service_without_active)
    expect(service.active).to eq(true)
  end

  context 'working days' do
    it 'is valid with 7 elements' do
      service = build(:service)
      service.service_working_days = build_list(:service_working_day, 7, service:)
      service.valid?
      expect(service).to be_valid
    end
    it 'is invalid with more than 7 elements' do
      service = build(:service)
      service.service_working_days = build_list(:service_working_day, 8, service:)
      service.valid?
      expect(service).not_to be_valid
    end
  end
end
