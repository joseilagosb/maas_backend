require 'rails_helper'

describe ServicesController do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }
  let(:service) { build(:service) }

  shared_examples 'user access to services' do
    describe 'GET #index' do
      it 'returns all services' do
        services = create_list(:service, 3) 
        get :index, format: :json
        expect(response.body).to eq(services.to_json)
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
