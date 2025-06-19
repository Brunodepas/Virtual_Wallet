require 'spec_helper'

RSpec.describe Saving, type: :model do
  let(:account) {
    Account.create!(
      alias: 'save_alias',
      cvu: '7777777777777777',
      balance: 3000,
      amount_point: 0,
      coin: 'Peso',
      status: 'Activo',
      level: '1',
      user: User.create!(
        username: 'savinguser',
        password: '1234',
        person: Person.create!(
          dni: '66666666',
          phone: '1112223333',
          email: 'save@example.com',
          first_name: 'Save',
          last_name: 'User',
          birth_date: '1999-01-01'
        )
      )
    )
  }

  it 'es válido con goal y current_amount >= 0' do
    saving = Saving.new(goal_amount: 2000, current_amount: 0, account: account)
    expect(saving).to be_valid
  end

  it 'detecta si se alcanzó la meta' do
    saving = Saving.new(goal_amount: 1000, current_amount: 1000, account: account)
    expect(saving.reached_goal?).to be true
  end
end
