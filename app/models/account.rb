class Account < ActiveRecord::Base
    #Relationships
    belongs_to :user

    #Validations
    VALID_COINS = ['Peso', 'Dólar']
    VALID_STATUS = ['Activo', 'Inactivo']
    VALID_LEVEL = ['1', '2', '3']

    #Valores válidos para esos atributos
    validates :coin, inclusion: { in: VALID_COINS }
    validates :status, inclusion: { in: VALID_STATUS }
    validates :level, inclusion: { in: VALID_LEVEL }
end