# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

# Instalación del proyecto

1.  Instalar las gemas con el comando
```bash
  bundle install 
```

2. Crear la base de datos y agregar migraciones y seeders con los comandos
```bash
  rails db:create
  rails db:migrate
  rails db:seed
```

3. Ejecutar el proyecto con el comando
```bash
  rails s
``` 


# Pruebas

Los tests unitarios y de features fueron realizados con **RSpec** siguiendo el principio de TDD (_Test Driven Development_). Para la ejecución de los tests se utilizó la gema **Guard**, que se encarga de ejecutar los tests en tiempo real y de notificar cuando se produzcan cambios en el código.

Para verificar los tests ejecutar el comando:

```bash
bundle exec rspec
```