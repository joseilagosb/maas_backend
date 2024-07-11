require 'rails_helper'

describe ServicesController do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }

  shared_examples 'user access to services' do
    describe 'GET #index' do
      it 'returns hello world' do
        get :index
        expect(response.body).to eq('hello world')
      end
    end
  end

  shared_examples 'full access to services' do
    describe 'GET #new' do
      it 'returns hello you must be an admin' do
        get 'new' do
          expect(response.body).to eq('hello you must be an admin')
        end
      end
    end

    describe 'POST #create' do
      it 'returns hello you must be an admin' do
        post :create
        expect(response.body).to eq('hello you must be an admin')
      end
    end 
  end

  describe 'is a user' do
    before :each do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in user
    end

    it_behaves_like 'user access to services'

    describe 'GET #new' do
      it 'denies access' do
        get :new
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq('nope you are not an admin')
      end
    end

    describe 'POST #create' do
      it 'denies access' do
        post :create
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
