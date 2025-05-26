class Person < ActiveRecord::Base
  has_many :users

  validates :dni, presence: true, uniqueness: true
  validates :phone, presence: true
  validates :email, presence: true
end
