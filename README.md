
# WINK 👀

Wink is a project for the systems analysis and design (2025) course of the third year of the computer science degree at the university of Rio Cuarto, Cordoba, Argentina.

## Team Members

- [Bruno de pasquale](https://www.github.com/brunodepas)
- [Emiliano Bernal](https://github.com/EmiBernal)
- [Genaro Oviedo](https://github.com/Genaro-Oviedo)
- [Juliana Sarmiento](https://github.com/julisarmiento)
- [Samuel Quintero](https://github.com/s4m0912)

## Used Technologies

- Ruby + Sinatra
- ActiveRecords
- contenedores Docker
- SQLite
- HTML, CSS
- FIGMA
- MIRO
## Running Instructions

Instructions to start the project:

- 1 locate in VIRTUAL_WALLET/app

- 2 install the necessary dependencies: docker compose build

- 3 build the server: docker compose up app -d

- 4 create the database: docker compose exec app bundle exec rake db:create

- 5 impact all migrations: docker compose exec app bundle exec rake db:migrate

- 6 downgrade the server: docker compose down app

## Usefull Links

Figma design: https://www.figma.com/design/Qqddlq60TSfLfXxufjsJLz/Dise%C3%B1o-TP-AyDS?node-id=0-1&t=gkaRwymhaGB4bgsA-1

Miro planning: https://miro.com/app/board/uXjVIJ8Yz1Y=/?share_link_id=683289137276