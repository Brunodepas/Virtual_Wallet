require 'spec_helper'

RSpec.describe Discount, type: :model do
  it 'es inválido si el porcentaje es mayor a 100' do
    discount = Discount.new(description: 'Super descuento', cost: 200, percentage: 150)
    discount.validate
    expect(discount.errors[:percentage]).to include("debe ser mayor a 0 y menor a 100")
  end
end
