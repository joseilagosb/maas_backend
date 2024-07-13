require 'rails_helper'
require 'matchers/serialized_equals'

describe ServicesController do
  let(:service) { build(:service) }
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }
  
  shared_examples 'user access to services' do
    describe 'GET #index' do
      it 'returns all services' do
        services = create_list(:service, 3) 
        get :index, format: :json

        parsed_services = JSON.parse(response.body)
        
        expect(parsed_services).to serialized_equals(services)
      end
    end

    describe 'GET #show' do
      it 'returns a service' do
        service = create(:service)
        get :show, params: { id: service.id }, format: :json

        parsed_body = JSON.parse(response.body)
        parsed_service = parsed_body["service"]
        parsed_service_weeks = parsed_body["included"]

        expect(parsed_service).to serialized_equals(service)
        expect(parsed_service_weeks).to serialized_equals(service.service_weeks)
      end
    end
  end

  shared_examples 'full access to services' do
    describe 'POST #create' do
      it 'creates a new service' do
        expect{
          post :create, params: { service: attributes_for(:service) }, format: :json
        }.to change(Service, :count).by(1)
      end
    end 
  end

  describe 'is a user' do
    before :each do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in user
    end

    it_behaves_like 'user access to services'

    describe 'POST #create' do
      it 'denies access' do
        post :create, format: :json
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq('nope you are not an admin')
      end
    end
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
