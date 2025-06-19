class CreateAdmin02 < ActiveRecord::Migration[8.0]
   def up
        person = Person.create!(
            dni: "00000002",
            first_name: "Admin",
            last_name: "02",
            birth_date: Date.new(2025, 6, 19),
            phone: "00000000",
            email: "winkAdmin02@gmail.com"
        )
        user = User.create!(
            username: "Admin02",
            password: "6admin425",  # ahora se guarda en password_digest!
            admin_check: true,
            person: person
        )
        Account.create!(
            alias: "Admin00000002",
            cvu: Time.current.strftime('%Y%m%d%H%M%S%6N') + "00000002",
            balance: 0,
            amount_point: 0,
            coin: "Peso",
            status: "Activo",
            level: "1",
            user: user
        )
    end
end
