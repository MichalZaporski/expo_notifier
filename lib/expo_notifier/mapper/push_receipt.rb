# typed: strict
# frozen_string_literal: true

require_relative 'base'
require_relative 'push_receipt_error_details'

module ExpoNotifier
  module Mapper
    class PushReceipt < Base
      attribute :status, Shale::Type::String, doc: <<~DOC
        Available values: 'error' | 'ok'
      DOC

      attribute :message, Shale::Type::String, doc: <<~DOC
        Error message. Only populated if `status` is equal to `error`.
      DOC

      attribute :details, PushReceiptErrorDetails, doc: <<~DOC
        Error details. Only populated if `status` is equal to `error`.
      DOC
    end
  end
end
