require 'spec_helper'

RSpec.describe User, type: :model do
  let(:person) {
    Person.create!(
      dni: '12345678',
      phone: '1234567890',
      email: 'usertest@example.com',
      first_name: 'Test',
      last_name: 'User',
      birth_date: '2001-01-01'
    )
  }

  it 'es válido con username y password' do
    user = User.new(username: 'usuario', password: '1234', person: person)
    expect(user).to be_valid
  end

  it 'no es válido sin username' do
    user = User.new(password: '1234', person: person)
    expect(user).not_to be_valid
  end

  it 'no es válido sin password' do
    user = User.new(username: 'usuario', person: person)
    expect(user).not_to be_valid
  end

  it 'requiere que username sea único' do
    User.create!(username: 'repetido', password: '1234', person: person)
    nuevo = User.new(username: 'repetido', password: 'abcd', person: person)
    expect(nuevo).not_to be_valid
  end
end
