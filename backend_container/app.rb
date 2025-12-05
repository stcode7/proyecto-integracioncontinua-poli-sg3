require 'sinatra'
require 'json'

# Necesario para que escuche desde fuera del contenedor
set(:bind, '0.0.0.0')

# Array en memoria para almacenar los todos
# Estructura: { id: 1, text: "Tarea ejemplo", done: false }
TODOS = []
NEXT_ID = 1

# Método auxiliar para responder JSON
def json_response(data, status_code = 200)
  content_type :json
  status status_code
  data.to_json
end

# Middleware para manejar CORS (permitir acceso desde el frontend)
before do
  response.headers['Access-Control-Allow-Origin'] = '*'
  response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
  response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
end

# Responder a OPTIONS para preflight checks de CORS
options '*' do
  200
end

get '/' do
  'Backend de ToDo List funcionando correctamente.'
end

# 1. GET /todos - Obtener todos los todos
get '/todos' do
  json_response(TODOS)
end

# 2. POST /todos - Crear un nuevo todo
post '/todos' do
  request.body.rewind
  payload = JSON.parse(request.body.read) rescue {}
  
  if payload['text'].nil? || payload['text'].strip.empty?
    return json_response({ error: 'El campo "text" es obligatorio' }, 400)
  end

  new_todo = {
    id: NEXT_ID,
    text: payload['text'],
    done: false
  }
  
  # Hack sucio para incrementar ID en Ruby sin variables globales complejas (usando const modificable)
  # En un app real usaríamos base de datos.
  TODOS << new_todo
  Object.send(:remove_const, :NEXT_ID)
  Object.const_set(:NEXT_ID, new_todo[:id] + 1)
  
  json_response(new_todo, 201)
end

# 3. PUT /todos/:id - Marcar como completado/incompleto
put '/todos/:id' do
  id = params[:id].to_i
  todo = TODOS.find { |t| t[:id] == id }
  
  return json_response({ error: 'Todo no encontrado' }, 404) unless todo

  request.body.rewind
  payload = JSON.parse(request.body.read) rescue {}
  
  # Actualizar estado 'done' si viene en el payload
  unless payload['done'].nil?
    todo[:done] = !!payload['done']
  end

  json_response(todo)
end

# 4. DELETE /todos/:id - Eliminar un todo
delete '/todos/:id' do
  id = params[:id].to_i
  todo = TODOS.find { |t| t[:id] == id }
  
  return json_response({ error: 'Todo no encontrado' }, 404) unless todo
  
  TODOS.delete(todo)
  json_response({ message: 'Todo eliminado' })
end
