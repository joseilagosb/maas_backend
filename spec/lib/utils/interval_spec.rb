require 'rails_helper'

describe Utils::Interval do
  let(:intervals) { JSON.parse(File.read('spec/fixtures/interval.json')) }

  context 'with valid parameters' do
    context 'shift'
    context 'remainder between intervals'
    context 'overlap or adjacent'
    context 'merge'
  end
end
