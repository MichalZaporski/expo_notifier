# typed: true
# frozen_string_literal: true

require 'test_helper'
require 'stringio'
require 'zlib'

module ExpoNotifier
  module Request
    class GetPushNotificationReceiptsTest < TestCase
      should 'get successful push notification receipts' do
        mapped_params = Mapper::PushReceiptIds.new(
          ids: %w[019b909b-e55c-7a0a-8ec5-ce89977b34b6 019b9339-aa4e-7e7e-84ac-840ee072e57e],
        )

        request = GetPushNotificationReceipts.new(mapped_params)

        cassette do
          request.execute
        end

        response = T.must(request.response)
        assert_equal 200, response.status_code
        assert response.duration.is_a?(Float)
        assert response.success?
        assert !response.malformed_request_error?
        assert !response.too_many_requests_error?
        assert !response.server_error?
        assert !response.communication_error?
        assert response.headers.is_a?(Hash)

        body = T.must(response.body)
        assert body.data.is_a?(Hash)
        assert_equal 2, body.data.size
        assert_equal [], body.errors

        receipt = body.data['019b909b-e55c-7a0a-8ec5-ce89977b34b6']
        assert_equal 'ok', receipt&.status
        assert_nil receipt&.message
        assert_nil receipt&.details

        receipt = body.data['019b9339-aa4e-7e7e-84ac-840ee072e57e']
        assert_equal 'ok', receipt&.status
        assert_nil receipt&.message
        assert_nil receipt&.details
      end

      should 'handle receipt with error status' do
        stub_request(:post, 'https://exp.host/--/api/v2/push/getReceipts')
          .to_return(
            status: 200,
            body:   '{"data":{"receipt-error":{"status":"error", "message":"E", "details":{"error":"MessageTooBig"}}}}',
          )

        mapped_params = Mapper::PushReceiptIds.new(
          ids: ['receipt-error'],
        )

        request = GetPushNotificationReceipts.new(mapped_params)
        request.execute

        response = T.must(request.response)
        assert_equal 200, response.status_code
        assert response.success?

        body = T.must(response.body)
        receipt = body.data['receipt-error']

        assert_equal 'error', receipt&.status
        assert_equal 'E', receipt&.message
        assert_equal 'MessageTooBig', receipt&.details&.error
      end

      should 'handle 400 response code' do
        mapped_params = Mapper::PushReceiptIds.new(
          ids: ['019b909b-e55c-7a0a-8ec5-ce89977b34b6'],
        )

        request = GetPushNotificationReceipts.new(mapped_params)

        cassette do
          request.execute
        end

        response = T.must(request.response)
        assert_equal 400, response.status_code
        assert !response.success?
        assert response.malformed_request_error?

        body = T.must(response.body)
        assert_nil body.data
        assert_equal 1, body.errors&.size

        error = body.errors&.first
        assert_equal 'PUSH_TOO_MANY_RECEIPTS', error&.code
        assert error&.message
      end

      should 'handle 429 response code' do
        stub_request(:post, 'https://exp.host/--/api/v2/push/getReceipts')
          .to_return(status: 429, body: '')

        mapped_params = Mapper::PushReceiptIds.new(
          ids: ['receipt-id'],
        )

        request = GetPushNotificationReceipts.new(mapped_params)
        request.execute

        response = T.must(request.response)
        assert_equal 429, response.status_code
        assert !response.success?
        assert response.too_many_requests_error?
        assert_nil response.body
      end

      should 'handle 500 response code' do
        stub_request(:post, 'https://exp.host/--/api/v2/push/getReceipts')
          .to_return(status: 500, body: '')

        mapped_params = Mapper::PushReceiptIds.new(
          ids: ['receipt-id'],
        )

        request = GetPushNotificationReceipts.new(mapped_params)
        request.execute

        response = T.must(request.response)
        assert_equal 500, response.status_code
        assert response.server_error?
        assert_nil response.body
      end

      should 'handle timeout' do
        stub_request(:post, 'https://exp.host/--/api/v2/push/getReceipts')
          .to_timeout

        mapped_params = Mapper::PushReceiptIds.new(
          ids: ['receipt-id'],
        )

        request = GetPushNotificationReceipts.new(mapped_params)
        request.execute

        response = T.must(request.response)
        assert_nil response.status_code
        assert response.communication_error?
        assert_equal '[Faraday::ConnectionFailed] => execution expired', response.communication_error_message
        assert_nil response.body
      end

      should 'build payload with all possible receipt parameters' do
        mapped_params = Mapper::PushReceiptIds.new(
          ids: %w[receipt-1 receipt-2],
        )

        request = GetPushNotificationReceipts.new(mapped_params)

        json = JSON.parse(request.raw_body)
        payload = json

        assert_equal(
          %w[receipt-1 receipt-2],
          payload['ids'],
        )
      end

      context 'request configuration' do
        setup do
          WebMock.enable!

          @body = Mapper::PushReceiptIds.new(
            ids: ['receipt-id'],
          )
        end

        teardown do
          WebMock.reset!
        end

        should 'use overridden base_url' do
          stub = stub_request(:post, 'https://example.test/--/api/v2/push/getReceipts')
                 .to_return(
                   status:  200,
                   body:    '{"data":{}}',
                   headers: { 'Content-Type' => 'application/json' },
                 )

          request = GetPushNotificationReceipts.new(
            @body,
            base_url: 'https://example.test',
          )

          request.execute
          assert_requested(stub)
        end

        should 'send Authorization header when access_token is provided' do
          stub = stub_request(:post, 'https://exp.host/--/api/v2/push/getReceipts')
                 .with(headers: { 'Authorization' => 'Bearer secret-token' })
                 .to_return(
                   status:  200,
                   body:    '{"data":{}}',
                   headers: { 'Content-Type' => 'application/json' },
                 )

          request = GetPushNotificationReceipts.new(
            @body,
            access_token: 'secret-token',
          )

          request.execute
          assert_requested(stub)
        end

        should 'merge additional_headers into request headers' do
          stub = stub_request(:post, 'https://exp.host/--/api/v2/push/getReceipts')
                 .with(headers: { 'X-Custom-Header' => 'custom' })
                 .to_return(
                   status:  200,
                   body:    '{"data":{}}',
                   headers: { 'Content-Type' => 'application/json' },
                 )

          request = GetPushNotificationReceipts.new(
            @body,
            additional_headers: { 'X-Custom-Header' => 'custom' },
          )

          request.execute
          assert_requested(stub)
        end

        should 'gzip request body and set Content-Encoding header' do
          request = GetPushNotificationReceipts.new(
            @body,
            gzip_min_size: 1,
          )

          stub = stub_request(:post, 'https://exp.host/--/api/v2/push/getReceipts')
                 .with do |req|
                   next false unless req.headers['Content-Encoding'] == 'gzip'

                   io = StringIO.new(req.body)
                   decompressed = Zlib::GzipReader.new(io).read
                   json = JSON.parse(decompressed)

                   json['ids'] == ['receipt-id']
                 end
                 .to_return(
                   status:  200,
                   body:    '{"data":{}}',
                   headers: { 'Content-Type' => 'application/json' },
                 )

          request.execute
          assert_requested(stub)
        end

        should 'send body as plain JSON when gzip is disabled' do
          request = GetPushNotificationReceipts.new(
            @body,
            gzip: false,
          )

          stub = stub_request(:post, 'https://exp.host/--/api/v2/push/getReceipts')
                 .with do |req|
                   next false if req.headers.key?('Content-Encoding')

                   json = JSON.parse(req.body)
                   json['ids'] == ['receipt-id']
                 end
                 .to_return(
                   status:  200,
                   body:    '{"data":{}}',
                   headers: { 'Content-Type' => 'application/json' },
                 )

          request.execute
          assert_requested(stub)
        end
      end
    end
  end
end
