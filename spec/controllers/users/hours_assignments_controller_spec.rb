require 'rails_helper'
require 'matchers/serialized_equals'
require 'factory_bot'

describe Users::HoursAssignmentsController do
  before do
    # Reiniciamos las secuencias para los datos a crear
    FactoryBot.reload
  end

  let(:user) { create(:user) }
  let(:service) { create(:service) }
  let(:service_week) { create(:service_week_with_days_and_hours, service:, minimal: true) }

  let(:user_hours_assignment) { build(:user_hours_assignment) }

  before :each do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in user
  end

  describe 'GET #index' do
    context 'with valid params' do
      it 'returns a 200 success status code' do
        get :index, params: { hours_assignment: { service_id: service.id, week: service_week.id } }
        expect(response).to have_http_status(:success)
      end

      it 'returns a list of hours assignments' do
        get :index, params: { hours_assignment: { service_id: service.id, week: service_week.id } }
        parsed_hours_assignments = response.parsed_body

        expect(parsed_hours_assignments).to serialized_equals([user_hours_assignment])
      end
    end

    context 'with invalid params' do
      context 'missing params' do
        it 'returns a 400 bad request status code' do
          get :index, params: { hours_assignment: {} }
          expect(response).to have_http_status(:bad_request)
        end
      end

      context 'missing service_id' do
        it 'returns a 400 bad request status code' do
          get :index, params: { hours_assignment: { service_id: nil, week: service_week.id } }
          expect(response).to have_http_status(:bad_request)
        end
      end

      context 'missing week' do
        it 'returns a 400 bad request status code' do
          get :index, params: { hours_assignment: { service_id: service.id, week: nil } }
          expect(response).to have_http_status(:bad_request)
        end
      end
    end
  end
end
