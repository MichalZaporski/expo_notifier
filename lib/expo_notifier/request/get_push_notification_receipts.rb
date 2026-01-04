# typed: strict
# frozen_string_literal: true

require_relative 'base'
require_relative '../mapper/push_receipt_ids'
require_relative '../mapper/push_receipts'

module ExpoNotifier
  module Request
    class GetPushNotificationReceipt < Base
      RequestBody  = type_member(:out) { { fixed: Mapper::PushReceiptIds } }
      ResponseBody = type_member(:out) { { fixed: Mapper::PushReceipts } }

      self.path = '/--/api/v2/push/getReceipts'
      self.response_class = Mapper::PushReceipts
    end
  end
end
