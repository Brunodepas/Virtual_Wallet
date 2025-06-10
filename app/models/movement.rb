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
      origin.update(amount_point: origin.amount_point + (amount * 100)/10000)
    end
  end

  def self.transfer(origin: ,destination: , amount:, reason:) 
    raise ArgumentError, "Cuenta origen y destino deben ser distintas" if origin.id == destination.id
    raise ArgumentError, "Cantidad a transferir no válida" if (amount <= 0 || amount > origin.balance)
    #raise ArgumentError, "Cuentas con distintos tipos de moneda" if (origin.coin != destination.coin) 
    #raise ArgumentError, "Cuenta emisora inactiva" if (origin.status == 'Inactivo')
    #raise ArgumentError, "Cuenta receptora inactiva" if (destination.status == 'Inactivo')
    #Si se agregan estos 3 errores, modificar historia de usuario asociada.

    ActiveRecord::Base.transaction do
      #Modifico balance de cuentas implicadas
      # Modificar balances
      origin.update!(balance: origin.balance - amount)
      origin.update!(amount_point: origin.amount_point + (amount * 75)/10000)
      destination.update!(balance: destination.balance + amount)

      #Registro la transferencia exitosa
      Movement.create!(
        amount: amount,
        date: Time.current,
        movement_type: 'Transferencia',
        status: 'Exitosa',
        reason: reason,
        origin: origin,
        destination: destination,
        history: origin,
        user: origin.user,
      )
    end

  rescue => error
    #Registro la transferencia fallida
    Movement.create!(
        amount: amount,
        date: Time.current,
        movement_type: 'Transferencia',
        status: 'Fallido',
        reason: error.message,
        origin: origin,
        destination: destination,
        history: origin,
        user: origin.user,
      )
      raise
  end
end