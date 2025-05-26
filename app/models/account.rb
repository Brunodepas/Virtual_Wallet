class Account < ActiveRecord::Base
    #Relationships
    belongs_to :user
    has_many :origin, class_name:'Movement', foreign_key: 'origin_id'
    has_many :destination, class_name:'Movement', foreign_key: 'destination_id'
    has_many :history, class_name:'Movement', foreign_key: 'history_id'
    has_many :savings

    #Validations
    VALID_COINS = ['Peso', 'Dólar']
    VALID_STATUS = ['Activo', 'Inactivo']
    VALID_LEVEL = ['1', '2', '3']

    #Valores válidos para esos atributos
    validates :coin, inclusion: { in: VALID_COINS }
    validates :status, inclusion: { in: VALID_STATUS }
    validates :level, inclusion: { in: VALID_LEVEL }
end