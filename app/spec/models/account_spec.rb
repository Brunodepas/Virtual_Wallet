require 'spec_helper'

RSpec.describe Account, type: :model do
  let(:user) {
    User.create!(
      username: 'tester',
      password: '1234',
      person: Person.create!(
        dni: '87654321',
        phone: '0987654321',
        email: 'user@example.com',
        first_name: 'Test',
        last_name: 'Account',
        birth_date: '1990-01-01'
      )
    )
  }

  it 'es válido con todos los campos requeridos' do
    cuenta = Account.new(
      alias: 'mi_alias',
      cvu: '1234567890000000',
      balance: 1000,
      amount_point: 0,
      coin: 'Peso',
      status: 'Activo',
      level: '1',
      user: user
    )
    expect(cuenta).to be_valid
  end

  it 'no permite monedas inválidas' do
    cuenta = Account.new(coin: 'Euro')
    cuenta.validate
    expect(cuenta.errors[:coin]).to include("is not included in the list")
  end
end
