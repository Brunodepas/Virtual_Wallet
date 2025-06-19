class User < ActiveRecord::Base
  belongs_to :person, dependent: :destroy
  has_many :accounts, dependent: :destroy
  
  #Bcrypt
  has_secure_password

  #Validaciones
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, on: :create
end
