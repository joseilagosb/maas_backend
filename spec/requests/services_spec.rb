require 'rails_helper'

RSpec.describe 'Services', type: :request do
  describe 'GET #index' do
    it 'returns hello world' do
      get '/services'
      expect(response.body).to eq('hello world')
    end
  end
end
