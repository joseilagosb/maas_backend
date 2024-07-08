require 'rails_helper'

describe Users::RegistrationsController do
  let(:user) { build(:user) }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'POST #create (sign up)' do
    context 'with valid params' do
      it 'creates a new User' do
        expect do
          post :create, params: { user: attributes_for(:user) }
        end.to change(User, :count).by(1)
      end

      it 'returns a 200 success status code' do
        post :create, params: { user: attributes_for(:user) }
        expect(response).to have_http_status(:success)
      end
    end

    context 'with invalid params' do
      it 'does not create a new User' do
        expect do
          post :create, params: { user: attributes_for(:user, email: nil) }
        end.not_to change(User, :count)
      end

      it 'returns a 422 unprocessable entity status code' do
        post :create, params: { user: attributes_for(:user, email: nil) }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when the user's email is already taken" do
      before do
        user.save!
      end

      it 'does not create a new User' do
        expect do
          post :create, params: { user: attributes_for(:user) }
        end.not_to change(User, :count)
      end

      it 'returns a 401 unauthorized status code' do
        post :create, params: { user: attributes_for(:user) }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
