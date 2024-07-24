require 'rails_helper'
require 'matchers/serialized_equals'

describe ServicesController do
  let(:service) { build(:service) }
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }

  shared_examples 'user access to services' do
    describe 'GET #index' do
      it 'returns all services' do
        services = create_list(:service_with_weeks_and_working_days, 3, minimal: true)
        get :index, format: :json
        parsed_services = response.parsed_body

        expect(parsed_services).to serialized_equals(services)
      end
    end

    describe 'GET #show' do
      it 'returns a service' do
        service = create(:service_with_weeks_and_working_days)
        get :show, params: { id: service.id }, format: :json
        parsed_service = response.parsed_body

        expect(parsed_service).to serialized_equals(service)
      end
    end
  end

  shared_examples 'full access to services' do
    pending 'POST #create'
  end

  describe 'is a user' do
    before :each do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in user
    end

    it_behaves_like 'user access to services'

    pending 'POST #create'
  end

  describe 'is an admin' do
    before :each do
      @request.env['devise.mapping'] = Devise.mappings[:admin]
      sign_in admin
    end

    it_behaves_like 'user access to services'
    it_behaves_like 'full access to services'
  end
end
