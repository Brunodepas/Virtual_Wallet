class Movement < ActiveRecord::Base
  #Relationships
  belongs_to :origin, class_name: 'Account'
  belongs_to :destination, class_name: 'Account'
  belongs_to :history, class_name: 'Account'
  belongs_to :user

  #Validations
  VALID_MOVEMENTS = ['Transferencia', 'Ingreso']
  VALID_STATUS = ['Pendiente', 'Fallido', 'Exitosa']

  #Valores válidos para esos atributos
  validates :type, inclusion: { in: VALID_MOVEMENTS }
  validates :status, inclusion: { in: VALID_STATUS }
end