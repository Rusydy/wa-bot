require 'http_status'
require_relative './whatsapp_service'

class ChatbotService
  def self.process_message(body)
    body_type = body["entry"][0]["changes"][0]["value"]["messages"][0]["type"]

    if body_type.nil?
      return {
        'status_code' => HTTPStatus::BadRequest,
        'message' => 'Missing message type'
      }
    end

    case body_type
    when 'text'
      return process_text_message(body)
    else
      return {
        'status_code' => HTTPStatus::NoContent,
        'message' => 'Invalid message type'
      }
    end
  end

  private

  def self.process_text_message(body)
    text = body["entry"][0]["changes"][0]["value"]["messages"][0]["text"]["body"]
    profile_name = body["entry"][0]["changes"][0]["value"]["contacts"][0]["profile"]["name"]
    wa_id = body["entry"][0]["changes"][0]["value"]["contacts"][0]["wa_id"]

    puts "Received message from #{profile_name} (#{wa_id}): #{text}"

    if text.nil?
      return {
        'status_code' => HTTPStatus::BadRequest,
        'message' => 'Missing text message'
      }
    end

    response = WhatsappService.send_text_message(profile_name, wa_id, text)
    unless response['status_code'] == HTTPStatus::Ok
      return {
        'status_code' => response['status_code'],
        'message' => response['message']
      }
    end

    {
      'status_code' => HTTPStatus::Ok,
      'message' => response['message']
    }
  end
end
