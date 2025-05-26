class User < ActiveRecord::Base
  belongs_to :person
  has_many :accounts
  
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true
end
