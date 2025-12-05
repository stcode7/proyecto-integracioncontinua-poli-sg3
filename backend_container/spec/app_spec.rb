require './spec/spec_helper'

describe 'ToDo List App' do
  before(:each) do
    # Limpiar estado entre tests (reiniciar array y contador)
    # Nota: Como usamos constantes modificables en el app.rb, esto es necesario para tests aislados
    TODOS.clear
    Object.send(:remove_const, :NEXT_ID) if Object.const_defined?(:NEXT_ID)
    Object.const_set(:NEXT_ID, 1)
  end

  it "says hello" do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Backend de ToDo List funcionando correctamente')
  end

  describe 'GET /todos' do
    it 'returns empty array initially' do
      get '/todos'
      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body)).to eq([])
    end
  end

  describe 'POST /todos' do
    it 'creates a new todo' do
      post '/todos', { text: 'Learn RSpec' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      puts "Response Body: #{last_response.body}" unless last_response.status == 201
      expect(last_response.status).to eq(201)
      
      body = JSON.parse(last_response.body)
      expect(body['text']).to eq('Learn RSpec')
      expect(body['id']).to eq(1)
      expect(body['done']).to eq(false)
    end

    it 'fails without text' do
      post '/todos', {}.to_json, { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(400)
    end
  end

  describe 'PUT /todos/:id' do
    before do
      post '/todos', { text: 'Task to update' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'toggles completion status' do
      put '/todos/1', { done: true }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body)['done']).to eq(true)
    end

    it 'returns 404 for unknown todo' do
      put '/todos/999', { done: true }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(404)
    end
  end

  describe 'DELETE /todos/:id' do
    before do
      post '/todos', { text: 'Task to delete' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'deletes the todo' do
      delete '/todos/1'
      expect(last_response).to be_ok
      
      get '/todos'
      expect(JSON.parse(last_response.body)).to be_empty
    end

    it 'returns 404 for unknown todo' do
      delete '/todos/999'
      expect(last_response.status).to eq(404)
    end
  end
end
