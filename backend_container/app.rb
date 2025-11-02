require 'sinatra'

# Necesario para que escuche desde fuera del contenedor
set(:bind, '0.0.0.0')

get '/' do
  'Hola desde el backend Ruby!'
end
