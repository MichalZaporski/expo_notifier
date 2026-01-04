# typed: strict
# frozen_string_literal: true

require_relative 'base'
require_relative 'push_ticket'
require_relative 'error'

module ExpoNotifier
  module Mapper
    class PushTickets < Base
      attribute :data, PushTicket, collection: true, doc: <<~DOC
        An array of Expo push tickets.

        The Expo push notification service responds with push tickets upon successfully receiving notifications.
        A push ticket indicates that Expo has received your notification payload but may still need to send it.
        Each push ticket contains a ticket ID, which you later use to look up a push receipt.
        A push receipt is available after Expo has tried to deliver the notification to FCM or APNs.
        It tells you whether delivery to the push notification provider was successful.
      DOC

      attribute :errors, Error, collection: true, doc: <<~DOC
        Errors — only populated if there was an error with the entire request.
      DOC
    end
  end
end
