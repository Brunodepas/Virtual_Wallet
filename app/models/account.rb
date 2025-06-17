class Account < ActiveRecord::Base
    #Relationships
    belongs_to :user
    has_many :origin, class_name:'Movement', foreign_key: 'origin_id', dependent: :destroy
    has_many :destination, class_name:'Movement', foreign_key: 'destination_id', dependent: :destroy
    has_many :history, class_name:'Movement', foreign_key: 'history_id', dependent: :destroy
    has_many :savings, dependent: :destroy
    has_many :AccountsPromo, dependent: :destroy
    has_many :promos, through: :AccountsPromo
    has_many :AccountsDiscount, dependent: :destroy
    has_many :discounts, through: :AccountsDiscount

    #Validations
    VALID_COINS = ['Peso', 'Dólar']
    VALID_STATUS = ['Activo', 'Inactivo']
    VALID_LEVEL = ['1', '2', '3']

    #Valores válidos para esos atributos
    validates :coin, inclusion: { in: VALID_COINS }
    validates :status, inclusion: { in: VALID_STATUS }
    validates :level, inclusion: { in: VALID_LEVEL }
    validates :alias, presence: true, uniqueness: true
    validates :cvu, presence: true, uniqueness: true
end