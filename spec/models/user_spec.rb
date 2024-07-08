describe User, type: :model do
  let(:user) { build(:user) }

  it 'is valid with a name, email and password' do
    user.valid?
    expect(user).to be_valid
  end

  it 'is invalid without a name' do
    user.name = nil
    user.valid?
    expect(user).to_not be_valid
  end

  it 'is invalid without an email' do
    user.email = nil
    user.valid?
    expect(user).to_not be_valid
  end

  context 'password validation' do
    it 'is invalid without a password' do
      user.password = nil
      user.valid?
      expect(user).to_not be_valid
    end

    # it 'is invalid with a password less than 6 characters' do
    #   user.password = Faker::Internet.password(min_length: 5)
    #   user.valid?
    #   expect(user).to_not be_valid
    # end

    # it 'is invalid with a password greater than 64 characters' do
    #   user.password = Faker::Internet.password(max_length: 64)
    #   user.valid?
    #   expect(user).to_not be_valid
    # end

    # it 'is invalid with a password that does not contain letters and numbers' do
    #   user.password = Faker::Internet.password(number: true, symbol: true)
    #   user.valid?
    #   expect(user).to_not be_valid
    # end
  end
end
