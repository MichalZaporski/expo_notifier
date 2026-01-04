# typed: strict
# frozen_string_literal: true

require_relative 'base'

module ExpoNotifier
  module Mapper
    class PushTicketErrorDetails < Base
      attribute :error, Shale::Type::String, doc: <<~DOC
        Available values:

        - DeviceNotRegistered: The device cannot receive push notifications anymore and you should stop
        sending messages to the corresponding Expo push token.
      DOC

      attribute :expo_push_token, Shale::Type::String
    end
  end
end
