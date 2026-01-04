# typed: strict
# frozen_string_literal: true

require_relative 'base'
require_relative 'push_ticket'
require_relative 'error'

module ExpoNotifier
  module Mapper
    class PushReceiptIds < Base
      attribute :ids, Shale::Type::String, collection: true, doc: <<~DOC
        An array of Expo push receipt ids.
      DOC
    end
  end
end
