require 'sinatra'
require 'dotenv/load'
require 'http_status'
require_relative 'src/controllers/main_controller'

set :port, ENV['APP_PORT'] || 8080

# health check endpoint
get '/health-check' do
  status HTTPStatus::Ok
  response.body = {
    status: 'ok',
    message: 'Service is up and running'
  }.to_json
end

# list of controllers
controllers = [
  MainController
]

# register controllers
controllers.each do |controller|
  use controller
end

# Trap ^C
Signal.trap('INT') {
  puts "\nShutting down..."
  Sinatra::Application.quit!
}

# Trap `Kill `
Signal.trap('TERM') {
  puts "\nShutting down..."
  Sinatra::Application.quit!
}
