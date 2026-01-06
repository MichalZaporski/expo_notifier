# typed: strict
# frozen_string_literal: true

require_relative 'expo_notifier/sorbet_shim'
require_relative 'expo_notifier/version'
require_relative 'expo_notifier/request/send_push_notifications'
require_relative 'expo_notifier/request/get_push_notification_receipts'

module ExpoNotifier
  class << self
    #: (String) -> bool
    def expo_push_token?(token)
      return false unless token.is_a?(String)

      ((token.start_with?('ExponentPushToken[') || token.start_with?('ExpoPushToken[')) && token.end_with?(']')) ||
        token.match?(/\A[a-z\d]{8}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{12}\z/i)
    end
  end
end
