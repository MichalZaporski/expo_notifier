# typed: strict
# frozen_string_literal: true

require_relative 'base'
require_relative 'push_ticket_error_details'

module ExpoNotifier
  module Mapper
    class PushTicket < Base
      attribute :status, Shale::Type::String, doc: <<~DOC
        Available values: 'error' | 'ok'

        A status of ok along with a receipt ID means that the message was received by Expo's servers,
        not that it was received by the user (for that you will need to check the push receipt).
      DOC

      attribute :id, Shale::Type::String, doc: <<~DOC
        The Receipt ID.
      DOC

      attribute :message, Shale::Type::String, doc: <<~DOC
        Error message. Only populated if `status` is equal to `error`.
      DOC

      attribute :details, PushTicketErrorDetails, doc: <<~DOC
        Error details. Only populated if `status` is equal to `error`.
      DOC
    end
  end
end
