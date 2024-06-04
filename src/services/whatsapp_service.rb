require 'http_status'
require 'net/http'

class WhatsappService
  def self.is_valid_whatsapp_message(body)
    checks = {
      %w[object] => 'Missing object in body',
      %w[entry] => 'Missing entry in body',
      %w[entry 0 changes] => 'Missing changes in entry',
      %w[entry 0 changes 0 value] => 'Missing value in changes',
      %w[entry 0 changes 0 value messages] => 'Missing messages in value',
      %w[entry 0 changes 0 value messages 0] => 'Missing first message in messages',
      %w[entry 0 changes 0 value contacts] => 'Missing contacts in value',
      %w[entry 0 changes 0 value contacts 0 wa_id] => 'Missing wa_id in first contact'
    }

    checks.each do |path, error_message|
      value = path.reduce(body) do |acc, key|
        acc.is_a?(Hash) ? acc[key] : acc.is_a?(Array) ? acc[key.to_i] : nil
      end
      return { 'error' => error_message, 'status_code' => HTTPStatus::BadRequest } if value.nil?
    end

    { 'status_code' => HTTPStatus::Ok }
  end

  def self.send_text_message(profile_name, wa_id, text)
    puts "Sending message to #{profile_name} (#{wa_id}): #{text}"

    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['ACCESS_TOKEN']}"
    }

    url = URI("https://graph.facebook.com/#{ENV['VERSION']}/#{ENV['PHONE_NUMBER_ID']}/messages")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url, headers)
    request.body = {
      "messaging_product" => "whatsapp",
      "recipient_type" => "individual",
      "to" => wa_id,
      "text" => {
        "body" => text,
        "preview_url" => "false"
      }
    }.to_json

    response = http.request(request)
    response_body = JSON.parse(response.body)

    unless response.code.to_i == HTTPStatus::Ok
      puts "response code: #{response.code}"
      puts "Error sending message: #{response_body}"
      return {
        'status_code' => HTTPStatus::InternalServerError,
        'message' => "error from server"
      }
    end

    {
      'status_code' => HTTPStatus::Ok,
      'message' => response_body
    }
  end
end
