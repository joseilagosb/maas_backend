require 'rails_helper'

RSpec.describe ServiceWeekSerializer, type: :serializer do
  let(:serializer) { described_class.new(service_week) }

  let(:service_week) { create(:service_week) }

  it('is a service week') do
    expect(serializer).to have_type(:service_week)
  end

  it('serializes the attributes') do
    expect(serializer).to have_attribute(:id)
    expect(serializer).to have_attribute(:week)
  end
end