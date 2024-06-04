require 'http_status'
require_relative '../services/whatsapp_service'
require_relative '../services/chatbot_service'

SUBSCRIBE_MODE = 'subscribe'.freeze

class MainController < Sinatra::Base
  # webhook verification endpoint
  get '/webhook' do
    mode = params['hub.mode']
    token = params['hub.verify_token']
    challenge = params['hub.challenge']

    unless mode && token
      error_message = {
        status: 'error',
        message: 'Missing mode and token parameters'
      }.to_json

      halt HTTPStatus::Forbidden, error_message
    end

    unless mode == SUBSCRIBE_MODE && token == ENV['VERIFY_TOKEN']
      error_message = {
        status: 'error',
        message: "Invalid mode (#{mode}) or token (#{token}"
      }.to_json

      halt HTTPStatus::BadRequest, error_message
    end

    # if everything is correct, return the challenge
    status HTTPStatus::Ok
    challenge
  end

  # webhook endpoint to receive messages
  post '/webhook' do
    body = request.body.read

    # Check if the body is empty or if it contains an empty JSON object
    if body.empty? || JSON.parse(body).empty?
      status_code = HTTPStatus::BadRequest
      error_message = {
        status: 'error',
        message: 'request body cannot be empty'
      }.to_json

      halt status_code, error_message
    end

    body = JSON.parse(body)

    # Check if it's a WhatsApp status update
    if body.dig('entry', 0, 'changes', 0, 'value', 'statuses')
      puts "Received a WhatsApp status update."

      update = body['entry'][0]['changes'][0]['value']['statuses'][0]['status']
      puts "Status: #{update}"

      halt HTTPStatus::NoContent, { status: update }.to_json
    end

    # Check if the message is valid
    check_event = WhatsappService.is_valid_whatsapp_message(body)
    unless check_event['error'].nil?
      status_code = HTTPStatus::BadRequest
      error_message = {
        status: 'error',
        message: check_event['error']
      }.to_json

      halt status_code, error_message
    end

    process = ChatbotService.process_message(body)
    unless process['status_code'] == HTTPStatus::Ok
      halt process['status_code'], {
        status: 'error',
        message: process['message']
      }.to_json
    end

    puts "Processed message successfully: #{process['message']}"
    status HTTPStatus::Ok
  end
end
