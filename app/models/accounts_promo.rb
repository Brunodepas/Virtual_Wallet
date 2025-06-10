class AccountsPromo < ActiveRecord::Base
  belongs_to :account
  belongs_to :promo
end
