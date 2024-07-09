require 'rails_helper'

describe ServicesController, type: :request do
  describe 'GET #index' do
    it 'returns hello world' do
      get '/services'
      expect(response.body).to eq('hello world')
    end
  end
end
