# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

- Ruby version

- System dependencies

- Configuration

- Database creation

- Database initialization

- How to run the test suite

- Services (job queues, cache servers, search engines, etc.)

- Deployment instructions

- ...

# Instalación del proyecto

**1.** Instalar las gemas con el comando

```bash
bundle install
```

**2.** Antes de crear la base de datos, debemos crear el secret del JWT para el entorno de desarrollo. Para ello ejecutamos el siguiente comando

```bash
bundle exec rails secret
```

**3.** El resultado del comando anterior es un hash largo que debe ser guardado en el archivo config/credentials.yml.enc. Para editarlo en nuestro editor de código ejecutamos en nuestra consola (para el ejemplo usaré VS Code):

```bash
EDITOR='code --wait' rails credentials:edit
```

Dentro del código insertamos el hash con la key _devise_jwt_secret_key_.

```
devise_jwt_secret_key: <el secret generado del paso anterior>
```

De manera alternativa, puedes insertarlo directamente en el archivo .env con el mismo atributo. Se verificará primero la existencia del secret en _credentials.yml.enc_ y luego en _.env_.

```
DEVISE_JWT_SECRET_KEY=<el secret generado del paso anterior>
```

**4.** Crear la base de datos y agregar migraciones y seeders con los comandos

```bash
rails db:create
rails db:migrate
rails db:seed
```

**5.** Ejecutar el proyecto con el comando

```bash
rails s
```

# Pruebas

Los tests unitarios y de features fueron realizados con **RSpec** siguiendo el principio de TDD (_Test Driven Development_). Para la ejecución de los tests se utilizó la gema **Guard**, que se encarga de ejecutar los tests en tiempo real según la ubicación del archivo modificado en nuestro proyecto.

Para verificar los tests ejecutar el comando:

```bash
bundle exec rspec
```
