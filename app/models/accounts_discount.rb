class AccountsDiscount < ActiveRecord::Base
  belongs_to :account
  belongs_to :discount
end
