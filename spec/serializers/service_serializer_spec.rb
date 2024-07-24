require 'rails_helper'

RSpec.describe ServiceSerializer, type: :serializer do
  let(:serializer) { described_class.new(service) }

  let(:service) { create(:service) }

  it 'is a service' do
    expect(serializer).to have_type(:service)
  end

  it 'serializes the attributes' do
    expect(serializer).to have_attribute(:id)
    expect(serializer).to have_attribute(:name)
    expect(serializer).to have_attribute(:active)
  end

  context 'with params[:method] = :show' do
    let(:serializer_with_params) { described_class.new(service, params: { method: :show }) }

    it 'serializes the relationships' do
      expect(serializer_with_params).to have_many(:service_weeks)
      expect(serializer_with_params).to have_many(:service_working_days)
    end
  end

  context 'without params[:method] = :show' do
    let(:serializer_without_params) { described_class.new(service) }

    it 'does not serialize the relationships' do
      expect(serializer_without_params).not_to have_many(:service_weeks)
      expect(serializer_without_params).not_to have_many(:service_working_days)
    end
  end
end
