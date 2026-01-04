# typed: true
# frozen_string_literal: true

require_relative 'base'
require_relative 'push_receipt'
require_relative 'error'

module ExpoNotifier
  module Mapper
    class PushReceipts < Base

      # Hash where keys are receipt IDs and values are push receipts
      #: Hash[String, PushReceipt]
      attr_accessor :data

      attribute :errors, Error, collection: true, doc: <<~DOC
        Errors — only populated if there was an error with the entire request.
      DOC

      json do
        map 'data', using: {
          from: :parse_push_receipts_from_json,
          to:   :undefined,
        }

        map 'errors', to: :errors
      end

      #: (ExpoNotifier::Mapper::PushReceipts, Hash[String, Object]) -> void
      def parse_push_receipts_from_json(model, value)
        model.data = value.transform_values do |receipt_hash|
          PushReceipt.from_hash(receipt_hash)
        end
      end

    end
  end
end
