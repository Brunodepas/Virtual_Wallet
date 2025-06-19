require 'spec_helper'

RSpec.describe Promo, type: :model do
  it 'no permite fecha pasada' do
    promo = Promo.new(
      description: 'Promo vencida',
      cost: 100,
      end_date: Date.yesterday
    )
    promo.validate
    expect(promo.errors[:end_date]).to include("debe ser una fecha futura")
  end
end
