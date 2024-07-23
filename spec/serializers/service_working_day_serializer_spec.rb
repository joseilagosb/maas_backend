require 'rails_helper'

RSpec.describe ServiceWorkingDaySerializer, type: :serializer do
  let(:serializer) { described_class.new(service_working_day) }

  let(:service_working_day) { create(:service_working_day) }

  it('is a service working day') do
    expect(serializer).to have_type(:service_working_day)
  end

  it('serializes the attributes') do
    expect(serializer).to have_attribute(:id)
    expect(serializer).to have_attribute(:day)
    expect(serializer).to have_attribute(:from)
    expect(serializer).to have_attribute(:to)
  end

  it('serializes the relationships') do
    expect(serializer).to belong_to(:service)
  end
end
