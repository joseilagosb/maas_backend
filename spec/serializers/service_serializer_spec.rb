require 'rails_helper'

RSpec.describe ServiceSerializer, type: :serializer do
  let(:serializer) { described_class.new(service) }

  let(:service) { create(:service) }

  it('is a service') do
    expect(serializer).to have_type(:service)
  end

  it('serializes the attributes') do
    expect(serializer).to have_attribute(:id)
    expect(serializer).to have_attribute(:name)
    expect(serializer).to have_attribute(:from)
    expect(serializer).to have_attribute(:to)
  end
end