require 'rails_helper'

RSpec.describe ServiceDaySerializer, type: :serializer do
  let(:serializer) { described_class.new(service_day) }

  let(:service_day) { create(:service_day) }

  it('is a service day') do
    expect(serializer).to have_type(:service_day)
  end

  it('serializes the attributes') do
    expect(serializer).to have_attribute(:id)
    expect(serializer).to have_attribute(:day)
  end

  it('serializes the relationships') do
    expect(serializer).to have_many(:service_hours)
  end
end
