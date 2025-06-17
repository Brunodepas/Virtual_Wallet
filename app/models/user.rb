class User < ActiveRecord::Base
  belongs_to :person, dependent: :destroy
  has_many :accounts, dependent: :destroy
  
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true
end
