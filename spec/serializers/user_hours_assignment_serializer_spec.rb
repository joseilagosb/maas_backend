require 'rails_helper'

RSpec.describe UserHoursAssignmentSerializer, type: :serializer do
  let(:serializer) { described_class.new(user_hours_assignment) }

  let(:user_hours_assignment) { build(:user_hours_assignment) }

  it('is a user hours assignment') do
    expect(serializer).to have_type(:user_hours_assignment)
  end

  it('serializes the attributes') do
    expect(serializer).to have_attribute(:id)
    expect(serializer).to have_attribute(:name)
    expect(serializer).to have_attribute(:color)
    expect(serializer).to have_attribute(:hours_count)
  end
end
