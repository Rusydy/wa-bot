require 'http_status'

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
end
