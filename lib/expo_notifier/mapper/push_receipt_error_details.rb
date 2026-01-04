# typed: strict
# frozen_string_literal: true

require_relative 'base'

module ExpoNotifier
  module Mapper
    class PushReceiptErrorDetails < Base
      attribute :error, Shale::Type::String, doc: <<~DOC
        Available values:

        - DeviceNotRegistered: The device cannot receive push notifications anymore and you should stop
        sending messages to the corresponding Expo push token.

        - MessageTooBig: The total notification payload was too large. On Android and iOS, the total payload must be at most 4096 bytes.

        - MismatchSenderId: This indicates that there is an issue with your FCM push credentials.

        - InvalidCredentials: Your push notification credentials for your standalone app are invalid.
      DOC
    end
  end
end
