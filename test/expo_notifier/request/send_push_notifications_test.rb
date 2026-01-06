# typed: true
# frozen_string_literal: true

require 'test_helper'
require 'stringio'
require 'zlib'

module ExpoNotifier
  module Request
    class SendPushNotificationsTest < TestCase
      should 'send successful push notification' do
        mapped_params = Mapper::PushMessages.build do |msgs|
          msgs.push_message do |msg|
            msg.to    = ['ExponentPushToken[J58oHWJwFIfCiY1ZAUd8tI]']
            msg.title = 'Test title'
            msg.body  = 'Test body'
            msg.data  = { order_id: 123 }
          end
        end

        request = SendPushNotifications.new(mapped_params)

        cassette do
          request.execute
        end

        response = T.must(request.response)
        assert response.success?, 'response should be successful'

        body = T.must(response.body)
        assert_equal 1, T.must(body.data).size

        ticket = T.must(body.data).first

        assert_equal 'ok', ticket&.status
        assert ticket&.id
        assert_nil ticket&.message
        assert_nil ticket&.details
      end

      should 'build payload with all possible push message parameters' do
        mapped_params = ExpoNotifier::Mapper::PushMessages.build do |msgs|
          msgs.push_message do |msg|
            msg.to = [
              'ExponentPushToken[xxxxxxxxxxxxxxxxxxxxxx]',
              'ExponentPushToken[yyyyyyyyyyyyyyyyyyyyyy]',
            ]
            msg.content_available   = true
            msg.data                = { foo: 'bar', count: 3 }
            msg.title               = 'Title'
            msg.body                = 'Body'
            msg.ttl                 = 3600
            msg.expiration          = 1_725_000_000
            msg.priority            = 'high'
            msg.subtitle            = 'Subtitle'
            msg.sound               = 'default'
            msg.badge               = 5
            msg.interruption_level  = 'time-sensitive'
            msg.channel_id          = 'orders'
            msg.icon                = 'notification_icon'
            msg.category_id         = 'order_updates'
            msg.mutable_content     = true
            msg.rich_content do |rich|
              rich.image = 'https://example.com/image.png'
            end
          end
        end

        request = ExpoNotifier::Request::SendPushNotifications.new(mapped_params)

        json = JSON.parse(request.raw_body)
        payload = json.first

        assert_equal(
          [
            'ExponentPushToken[xxxxxxxxxxxxxxxxxxxxxx]',
            'ExponentPushToken[yyyyyyyyyyyyyyyyyyyyyy]',
          ],
          payload['to'],
        )
        assert_equal true, payload['_contentAvailable']
        assert_equal({ 'foo' => 'bar', 'count' => 3 }, payload['data'])
        assert_equal 'Title', payload['title']
        assert_equal 'Body', payload['body']
        assert_equal 3600, payload['ttl']
        assert_equal 1_725_000_000, payload['expiration']
        assert_equal 'high', payload['priority']
        assert_equal 'Subtitle', payload['subtitle']
        assert_equal 'default', payload['sound']
        assert_equal 5, payload['badge']
        assert_equal 'time-sensitive', payload['interruptionLevel']
        assert_equal 'orders', payload['channelId']
        assert_equal 'notification_icon', payload['icon']
        assert_equal 'order_updates', payload['categoryId']
        assert_equal true, payload['mutableContent']
        assert_equal(
          { 'image' => 'https://example.com/image.png' },
          payload['richContent'],
        )
      end

      context 'request configuration' do
        setup do
          WebMock.enable!

          @body = ExpoNotifier::Mapper::PushMessages.build do |msgs|
            msgs.push_message do |msg|
              msg.to   = ['ExpoPushToken[xxxxxxxxxxxxxxxxxxxxxx]']
              msg.body = 'Test body'
            end
          end
        end

        teardown do
          WebMock.reset!
        end

        should 'use overridden base_url' do
          stub = stub_request(:post, 'https://example.test/--/api/v2/push/send')
                 .to_return(
                   status:  200,
                   body:    '{"data":[]}',
                   headers: { 'Content-Type' => 'application/json' },
                 )

          request = ExpoNotifier::Request::SendPushNotifications.new(
            @body,
            base_url: 'https://example.test',
          )

          request.execute

          assert_requested(stub)
        end

        should 'send Authorization header when access_token is provided' do
          stub = stub_request(:post, 'https://exp.host/--/api/v2/push/send')
                 .with(
                   headers: {
                     'Authorization' => 'Bearer secret-token',
                   },
                 )
                 .to_return(
                   status:  200,
                   body:    '{"data":[]}',
                   headers: { 'Content-Type' => 'application/json' },
                 )

          request = ExpoNotifier::Request::SendPushNotifications.new(
            @body,
            access_token: 'secret-token',
          )

          request.execute

          assert_requested(stub)
        end

        should 'merge additional_headers into request headers' do
          stub = stub_request(:post, 'https://exp.host/--/api/v2/push/send')
                 .with(
                   headers: {
                     'X-Custom-Header' => 'custom',
                   },
                 )
                 .to_return(
                   status:  200,
                   body:    '{"data":[]}',
                   headers: { 'Content-Type' => 'application/json' },
                 )

          request = ExpoNotifier::Request::SendPushNotifications.new(
            @body,
            additional_headers: {
              'X-Custom-Header' => 'custom',
            },
          )

          request.execute

          assert_requested(stub)
        end

        should 'gzip request body and set Content-Encoding header' do
          request = ExpoNotifier::Request::SendPushNotifications.new(
            @body,
            gzip_min_size: 1,
          )

          stub = stub_request(:post, 'https://exp.host/--/api/v2/push/send')
                 .with do |req|
                   next false unless req.headers['Content-Encoding'] == 'gzip'

                   io = StringIO.new(req.body)
                   decompressed = Zlib::GzipReader.new(io).read
                   json = JSON.parse(decompressed)

                   json.first['body'] == 'Test body'
          end.to_return( # rubocop:disable Style/MethodCalledOnDoEndBlock
            status:  200,
            body:    '{"data":[]}',
            headers: { 'Content-Type' => 'application/json' },
          )

          request.execute

          assert_requested(stub)
        end

        should 'send body as plain JSON when gzip is disabled' do
          request = ExpoNotifier::Request::SendPushNotifications.new(
            @body,
            gzip: false,
          )

          stub = stub_request(:post, 'https://exp.host/--/api/v2/push/send')
                 .with do |req|
                   next false if req.headers.key?('Content-Encoding')

                   json = JSON.parse(req.body)
                   json.first['body'] == 'Test body'
          end.to_return( # rubocop:disable Style/MethodCalledOnDoEndBlock
            status:  200,
            body:    '{"data":[]}',
            headers: { 'Content-Type' => 'application/json' },
          )

          request.execute

          assert_requested(stub)
        end
      end

    end
  end
end
