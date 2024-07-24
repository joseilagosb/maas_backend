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

  context('with params[:method] = :show') do
    let(:serializer_with_params) { described_class.new(service_hour, params: { method: :show }) }

    it('serializes the designated user') do
      expect(serializer_with_params).to belong_to(:designated_user)
    end

    it('does not serialize the users') do
      expect(serializer_with_params).not_to have_many(:users)
    end
  end

  context('with params[:method] = :edit') do
    let(:serializer_with_params) { described_class.new(service_hour, params: { method: :edit }) }

    it('does not serialize the designated user') do
      expect(serializer_with_params).not_to belong_to(:designated_user)
    end

    it('serializes the users') do
      expect(serializer_with_params).to have_many(:users)
    end
  end

  context 'without params[:method]' do
    let(:serializer_without_params) { described_class.new(service_hour) }

    it('does not serialize the designated user') do
      expect(serializer_without_params).not_to belong_to(:designated_user)
    end

    it('does not serialize the users') do
      expect(serializer_without_params).not_to have_many(:users)
    end
  end 
end
