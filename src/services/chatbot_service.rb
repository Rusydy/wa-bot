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

    if body_type == 'text'
      return process_text_message(body)
    elsif body_type == 'interactive'
      return process_interactive_message(body)
    else
      return {
        'status_code' => HTTPStatus::BadRequest,
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

    # TODO: Implement this later
    # receiver = {
    #   'profile_name' => profile_name,
    #   'wa_id' => wa_id
    # }.freeze

    # flow for the text message
    if text.downcase == 'hello' || text.downcase == 'hi' || text.downcase == 'hey'
      send_greeting_message(profile_name, wa_id)
      send_instruction_message(profile_name, wa_id)
    elsif text == '1'
      send_registration_message(profile_name, wa_id)
    else
      send_error_message(profile_name, wa_id)
    end

    {
      'status_code' => HTTPStatus::Ok,
      'message' => response['message']
    }
  end

  def self.send_greeting_message(profile_name, wa_id)
    text = "Hello #{profile_name}!"
    WhatsappService.send_text_message(profile_name, wa_id, text)

    puts "Sent greeting message to #{profile_name} (#{wa_id}): #{text}"
  end

  def self.send_instruction_message(profile_name, wa_id)
    text = "Please type 'help' for a list of available commands."
    text += "\nType 1 for the registration."

    WhatsappService.send_text_message(profile_name, wa_id, text)

    puts "Sent instruction message to #{profile_name} (#{wa_id}): #{text}"
  end

  def self.send_registration_message(profile_name, wa_id)
    # TODO: implement Whatsapp FLOW for registration
    # send a registration form using flow
  end

  def self.send_error_message(profile_name, wa_id)
    text = "Sorry, I don't understand what you mean."
    text += "\nHere is the instruction:"
    text += "\nType 1 for the registration."

    WhatsappService.send_text_message(profile_name, wa_id, text)

    puts "Sent error message to #{profile_name} (#{wa_id}): #{text}"
  end
end
