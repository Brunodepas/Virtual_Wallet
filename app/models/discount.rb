class Discount < ActiveRecord::Base
  #Relationships
  has_many :AccountsDiscount
  has_many :accounts, through: :AccountsDiscount

  #Validations
  validates :description, presence: true
  validates :cost, presence: true
  validates :cost, presence: true, numericality: { greater_than: 0, message: "debe ser mayor a 0" }
  validates :percentage, presence: true, numericality: { greater_than: 0, less_than: 100, message: "debe ser mayor a 0 y menor a 100" }
end