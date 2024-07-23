require 'rails_helper'

RSpec.describe ServiceHourSerializer, type: :serializer do
  let(:serializer) { described_class.new(service_hour) }

  let(:service_hour) { create(:service_hour) }

  it('is a service hour') do
    expect(serializer).to have_type(:service_hour)
  end

  it('serializes the attributes') do
    expect(serializer).to have_attribute(:id)
    expect(serializer).to have_attribute(:hour)
  end

  pending 'serializes the relationships (figure out how to assess passing params)'
end
