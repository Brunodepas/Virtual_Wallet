require 'spec_helper'

RSpec.describe Movement, type: :model do
  let(:user) {
    User.create!(
      username: 'mov_user',
      password: '1234',
      person: Person.create!(
        dni: '55555555',
        phone: '1112223333',
        email: 'mov@example.com',
        first_name: 'Mov',
        last_name: 'User',
        birth_date: '1995-01-01'
      )
    )
  }

  let(:cuenta) {
    Account.create!(
      alias: 'mov_cuenta',
      cvu: '9876543210000000',
      balance: 2000,
      amount_point: 0,
      coin: 'Peso',
      status: 'Activo',
      level: '1',
      user: user
    )
  }

  it 'es válido un ingreso pendiente' do
    mov = Movement.new(
      amount: 500,
      movement_type: 'Ingreso',
      status: 'Pendiente',
      origin: cuenta,
      history: cuenta,
      date: Time.now
    )
    expect(mov).to be_valid
  end

  it 'no permite montos negativos' do
    mov = Movement.new(amount: -100, movement_type: 'Ingreso', status: 'Pendiente')
    mov.validate
    expect(mov.errors[:amount]).to include("debe ser mayor a cero")
  end

  describe '.transfer' do
    let(:destino) {
      Account.create!(
        alias: 'cuenta_dest',
        cvu: '1112223334445555',
        balance: 1000,
        amount_point: 0,
        coin: 'Peso',
        status: 'Activo',
        level: '1',
        user: user
      )
    }

    it 'realiza una transferencia válida y registra el movimiento' do
      expect {
        Movement.transfer(origin: cuenta, destination: destino, amount: 500, reason: 'Prueba')
      }.to change { Movement.count }.by(1)

      mov = Movement.last
      expect(mov.status).to eq("Exitosa")
      expect(cuenta.reload.balance).to eq(1500)
      expect(destino.reload.balance).to eq(1500)
    end
  end
end
