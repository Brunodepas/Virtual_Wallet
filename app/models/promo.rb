class Promo < ActiveRecord::Base
  #Relationships
  has_many :AccountsPromo, dependent: :destroy
  has_many :accounts, through: :AccountsPromo

  #Validations
  validates :description, presence: true
  validates :end_date, presence: true
  validates :cost, presence: true, numericality: { greater_than: 0, message: "debe ser mayor a 0" }
  validate :end_date_future

  private def end_date_future
    if end_date.present? && end_date <= Date.today
      errors.add(:end_date, "debe ser una fecha futura")
    end
  end
end