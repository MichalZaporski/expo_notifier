# typed: strict
# frozen_string_literal: true

require_relative 'base'
require_relative 'push_message'

module ExpoNotifier
  module Mapper
    class PushMessages < Base
      attribute :push_message, PushMessage, collection: true, doc: <<~DOC
        An array of push messages.
      DOC
    end
  end
end
