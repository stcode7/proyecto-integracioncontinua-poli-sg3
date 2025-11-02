# Imagen base con Ruby
FROM ruby:3.3

# Directorio de trabajo dentro del contenedor
WORKDIR /usr/src/app

# Copiamos Gemfile primero para aprovechar cache de Docker
COPY Gemfile Gemfile.lock ./

# Instalamos las gemas necesarias
RUN bundle install

# Copiamos el resto de la aplicación
COPY . .

# Puerto en el que correrá la app
EXPOSE 4567

# Comando por defecto
CMD ["ruby", "app.rb"]
