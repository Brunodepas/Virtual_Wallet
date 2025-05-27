class Movement < ActiveRecord::Base
  #Relationships
  belongs_to :origin, class_name: 'Account'
  belongs_to :destination, class_name: 'Account'
  belongs_to :history, class_name: 'Account'
  belongs_to :user

  #Validations
  VALID_MOVEMENTS = ['Transferencia', 'Ingreso']
  VALID_STATUS = ['Pendiente', 'Fallido', 'Exitosa','Rechazada']

  #Valores válidos para esos atributos
  validates :movement_type, inclusion: { in: VALID_MOVEMENTS }
  validates :status, inclusion: { in: VALID_STATUS }
  validates :amount, numericality: { greater_than: 0, message: "debe ser mayor a cero" }

  #trigger para ingreso de dinero
  after_update :ingresoDinero

  private def ingresoDinero
    if saved_change_to_status? && movement_type == 'Ingreso' && status == 'Exitosa'
      origin.update(balance: origin.balance + amount)
    end
  end
end