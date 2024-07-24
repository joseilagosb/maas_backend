require 'rails_helper'

RSpec.describe UserSerializer, type: :serializer do
  let(:serializer) { described_class.new(user) }

  let(:user) { create(:user) }

  it('is a user') do
    expect(serializer).to have_type(:user)
  end

  it('serializes the attributes') do
    expect(serializer).to have_attribute(:id)
    expect(serializer).to have_attribute(:name)
    expect(serializer).to have_attribute(:email)
    expect(serializer).to have_attribute(:role)
    expect(serializer).to have_attribute(:color)
  end
end