# typed: true
# frozen_string_literal: true

require 'test_helper'

class ExpoNotifierTest < Minitest::Test
  should 'has a version' do
    refute_nil ExpoNotifier::VERSION
  end

  context '#expo_push_token?' do
    should 'accept ExponentPushToken format' do
      token = 'ExponentPushToken[abcdef123456]'
      assert ExpoNotifier.expo_push_token?(token)
    end

    should 'accept ExpoPushToken format' do
      token = 'ExpoPushToken[abcdef123456]'
      assert ExpoNotifier.expo_push_token?(token)
    end

    should 'accept UUID format' do
      token = '123e4567-e89b-12d3-a456-426614174000'
      assert ExpoNotifier.expo_push_token?(token)
    end

    should 'accept UUID format with uppercase letters' do
      token = '123E4567-E89B-12D3-A456-426614174000'
      assert ExpoNotifier.expo_push_token?(token)
    end

    should 'reject non-string values' do
      refute T.unsafe(ExpoNotifier).expo_push_token?(nil) # rubocop:disable Sorbet/ForbidTUnsafe
      refute T.unsafe(ExpoNotifier).expo_push_token?(123) # rubocop:disable Sorbet/ForbidTUnsafe
      refute T.unsafe(ExpoNotifier).expo_push_token?({}) # rubocop:disable Sorbet/ForbidTUnsafe
    end

    should 'reject invalid string formats' do
      invalid_tokens = [
        '',
        'ExpoPushToken[',
        'ExpoPushToken]',
        'ExpoPushToken[abc',
        'ExponentPushTokenabc]',
        '123e4567-e89b-12d3-a456-42661417400',
      ]

      invalid_tokens.each do |token|
        refute ExpoNotifier.expo_push_token?(token), "Expected #{token.inspect} to be invalid"
      end
    end
  end
end
