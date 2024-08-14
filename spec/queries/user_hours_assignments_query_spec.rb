require 'rails_helper'

RSpec.describe UserHoursAssignmentsQuery do
  before do
    @user = create(:user)
    @service = create(:service_with_weeks_and_working_days)
    @service_week = create(:service_week_with_days_and_hours, service: @service, minimal: true)
    @user_hours_assignment = build(:user_hours_assignment)
  end

  context 'with valid options' do
    it 'returns a list of hours assignments' do
      query = UserHoursAssignmentsQuery.new(initial_scope: User.all,
                                            options: {
                                              service_id: @service.id, week: @service_week.week
                                            })
      result = query.call
      expect(result.length).to eq([@user_hours_assignment].length)
      expect(result[0].name).to eq(@user_hours_assignment.name)
      expect(result[0].color).to eq(@user_hours_assignment.color)
      expect(result[0].hours_count).to eq(@user_hours_assignment.hours_count)
    end
  end

  context 'with invalid options' do
    context 'missing options object' do
      it 'raises an ArgumentError' do
        expect { UserHoursAssignmentsQuery.new(initial_scope: User.all, options: {}) }.to raise_error(ArgumentError)
      end
    end

    context 'missing service_id' do
      it 'raises an ArgumentError' do
        expect do
          UserHoursAssignmentsQuery.new(initial_scope: User.all,
                                        options: { week: @service_week.week })
        end.to raise_error(ArgumentError)
      end
    end

    context 'missing week' do
      it 'raises an ArgumentError' do
        expect do
          UserHoursAssignmentsQuery.new(initial_scope: User.all,
                                        options: { service_id: @service.id })
        end.to raise_error(ArgumentError)
      end
    end

    context 'service_id not linked to a service' do
      it 'raises an ArgumentError' do
        expect do
          UserHoursAssignmentsQuery.new(initial_scope: User.all,
                                        options: { service_id: 0, week: @service_week.week })
        end.to raise_error(ArgumentError)
      end
    end
  end
end
