require 'rails_helper'

RSpec.describe UserHoursAssignment, type: :model do
  it 'is valid' do
    user_hours_assignment = build(:user_hours_assignment)
    user_hours_assignment.valid?
    expect(user_hours_assignment).to be_valid
  end

  it 'is invalid without a name' do
    user_hours_assignment = build(:user_hours_assignment, name: nil)
    user_hours_assignment.valid?
    expect(user_hours_assignment).to_not be_valid
  end

  context 'color validation' do
    it 'is invalid without a color' do
      user_hours_assignment = build(:user_hours_assignment, color: nil)
      user_hours_assignment.valid?
      expect(user_hours_assignment).to_not be_valid
    end

    it 'is invalid with a color out of range' do
      user_hours_assignment = build(:user_hours_assignment, color: 7)
      user_hours_assignment.valid?
      expect(user_hours_assignment).to_not be_valid
    end
  end

  context 'hours_count validation' do
    it 'is invalid without hours_count' do
      user_hours_assignment = build(:user_hours_assignment, hours_count: nil)
      user_hours_assignment.valid?
      expect(user_hours_assignment).to_not be_valid
    end

    it 'is invalid with hours_count less than 0' do
      user_hours_assignment = build(:user_hours_assignment, hours_count: -1)
      user_hours_assignment.valid?
      expect(user_hours_assignment).to_not be_valid
    end
  end
end
