# typed: strict
# frozen_string_literal: true

require_relative 'base'
require_relative '../mapper/push_messages'
require_relative '../mapper/push_tickets'

module ExpoNotifier
  module Request
    class SendPushNotifications < Base
      RequestBody  = type_member(:out) { { fixed: Mapper::PushMessages } }
      ResponseBody = type_member(:out) { { fixed: Mapper::PushTickets } }

      self.path = '/--/api/v2/push/send'
      self.response_class = Mapper::PushTickets

      # String in the JSON format
      # We override the raw body to send an array as a main object.
      #: -> String
      def raw_body
        @raw_body ||= ExpoNotifier::Mapper::PushMessage.to_json(body.push_message) #: String?
      end

    end
  end
end
