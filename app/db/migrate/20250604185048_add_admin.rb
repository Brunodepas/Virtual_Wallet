require_relative '../../models/person'
require_relative '../../models/user'
require_relative '../../models/account'

class AddAdmin < ActiveRecord::Migration[8.0]
    def up
        person = Person.create!(
            dni: "00000001",
            first_name: "Admin",
            last_name: "01",
            birth_date: Date.new(2025, 6, 4),
            phone: "00000000",
            email: "winkAdmin01@gmail.com"
        )
        user = User.create!(
            username: "Admin01",
            password: "6admin425",
            admin_check: true,
            person: person
        )
        account = Account.create!(
            alias: "Admin00000001",
            cvu: Time.current.strftime('%Y%m%d%H%M%S%6N') + "00000001",
            balance: 0,
            amount_point: 0,
            coin: "Peso",
            status: "Activo",
            level: "1",
            user: user
        )
    end
end
