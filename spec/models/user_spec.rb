require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is valid with a name, email and password' do
    user = build(:user)
    user.valid?
    expect(user).to be_valid
  end

  it 'is invalid without a name' do
    user = build(:user, name: nil)
    user.valid?
    expect(user).to_not be_valid
  end

  it 'is invalid without an email' do
    user = build(:user, email: nil)
    user.valid?
    expect(user).to_not be_valid
  end

  context 'password validation' do
    it 'is invalid without a password' do
      user = build(:user, password: nil)
      user.valid?
      expect(user).to_not be_valid
    end

    it 'is invalid with a password less than 6 characters' do
      user = build(:user, password: Faker::Internet.password(min_length: 2, max_length: 5))
      user.valid?
      expect(user).to_not be_valid
    end

    it 'is invalid with a password greater than 64 characters' do
      user = build(:user, password: Faker::Internet.password(min_length: 65, max_length: 100))
      user.valid?
      expect(user).to_not be_valid
    end
  end

  context 'when an attribute is already taken' do
    before do
      create(:user)
    end

    it 'does not create a new User with the same email' do
      user = build(:user, name: 'otro_pepe')
      user.valid?
      expect(user).to_not be_valid
    end

    it 'does not create a new User with the same name' do
      user = build(:user, email: 'otro_pepe@maas.com')
      user.valid?
      expect(user).to_not be_valid
    end
  end
end
