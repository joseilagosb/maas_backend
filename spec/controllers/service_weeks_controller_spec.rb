require 'rails_helper'
require 'matchers/serialized_equals'

describe ServiceWeeksController do
  let(:admin) { create(:admin) }
  let(:users) { create_list(:fake_user, 3) }
  let(:service_week) { create(:service_week_with_days_and_hours, minimal: true) }

  shared_examples 'access to service weeks' do
    describe 'GET #show' do
      it 'returns a service week' do
        get :show, params: { id: service_week.id, service_id: service_week.service.id }, format: :json
        parsed_service_week = response.parsed_body

        expect(parsed_service_week).to serialized_equals(service_week)
      end
    end

    describe 'GET #edit' do
      it 'returns a service week' do
        get :edit, params: { id: service_week.id, service_id: service_week.service.id }, format: :json
        parsed_service_week = response.parsed_body

        expect(parsed_service_week).to serialized_equals(service_week)
      end
    end

    pending 'PATCH #update'
    pending 'POST #create'
  end

  describe 'is a user' do
    before :each do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in users.first
    end

    it_behaves_like 'access to service weeks'
  end

  describe 'is an admin' do
    before :each do
      @request.env['devise.mapping'] = Devise.mappings[:admin]
      sign_in admin
    end

    it_behaves_like 'access to service weeks'
  end
end
