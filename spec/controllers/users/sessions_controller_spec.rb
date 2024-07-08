require 'rails_helper'

describe Users::SessionsController do
  let(:user) { create(:user) }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'POST #create (login)' do
    context 'with valid params' do
      it 'logs the user in' do
        post :create, params: { user: { email: user.email, password: user.password } }
        expect(controller.current_user).to eq(user)
      end
      it 'returns a 200 success status code' do
        post :create, params: { user: { email: user.email, password: user.password } }
        expect(response).to have_http_status(:success)
      end
    end

    context 'with invalid params' do
      it 'does not log the user in' do
        post :create, params: { user: { email: user.email, password: 'contrasena_incorrecta' } }
        expect(controller.current_user).to be_nil
      end

      it 'returns a 401 unauthorized status code' do
        post :create, params: { user: { email: user.email, password: 'contrasena_incorrecta' } }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
