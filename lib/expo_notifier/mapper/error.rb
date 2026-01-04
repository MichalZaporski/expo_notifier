# typed: strict
# frozen_string_literal: true

require_relative 'base'

module ExpoNotifier
  module Mapper
    class Error < Base
      attribute :code, Shale::Type::String, doc: <<~DOC
        Available values:

        - TOO_MANY_REQUESTS: You are exceeding the request limit of 600 notifications per second per project.

        - PUSH_TOO_MANY_EXPERIENCE_IDS: You are trying to send push notifications to different Expo experiences.

        - PUSH_TOO_MANY_NOTIFICATIONS: You are trying to send more than 100 push notifications in one request.

        - PUSH_TOO_MANY_RECEIPTS: You are trying to get more than 1000 push receipts in one request.
      DOC

      attribute :message, Shale::Type::String
    end
  end
end
