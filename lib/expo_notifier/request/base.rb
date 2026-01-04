# typed: true
# frozen_string_literal: true

require 'faraday'
require 'uri'
require 'stringio'
require 'zlib'

require_relative '../mapper/base'
require_relative '../response'

module ExpoNotifier
  module Request
    # An abstract class for building and sending requests.
    # @abstract
    class Base
      extend T::Sig
      extend T::Generic

      RequestBody  = type_member(:out) { { upper: Mapper::Base } }
      ResponseBody = type_member(:out) { { upper: Mapper::Base } }

      Generic = T.type_alias { Base[Mapper::Base, Mapper::Base] }

      ########## ---------- Default config ---------- ##########
      BASE_URL        = 'https://exp.host'
      WRITE_TIMEOUT   = 5
      OPEN_TIMEOUT    = 5
      READ_TIMEOUT    = 30
      GZIP_MIN_SIZE = 1024
      BASE_HEADERS    = {
        'Content-Type'    => 'application/json',
        'Accept'          => 'application/json',
        'Accept-Encoding' => 'gzip, deflate',
      }.freeze #: Hash[String, String]
      ########## ------------------------------------ ##########

      class << self
        #: String
        attr_accessor :path

        #: singleton(Mapper::Base)
        attr_accessor :response_class
      end

      #: String
      attr_reader :url

      #: RequestBody
      attr_reader :body

      #: Response[ResponseBody]?
      attr_reader :response

      #: (
      #|  RequestBody,
      #|  ?access_token:       String?,
      #|  ?faraday_adapter:    Symbol,
      #|  ?base_url:           String,
      #|  ?write_timeout:      Integer,
      #|  ?open_timeout:       Integer,
      #|  ?read_timeout:       Integer,
      #|  ?gzip:               bool,
      #|  ?gzip_min_size:      Integer,
      #|  ?additional_headers: Hash[String, String]?,
      #| ) -> void
      def initialize(
        body,
        access_token:       nil,
        faraday_adapter:    Faraday.default_adapter,
        base_url:           BASE_URL,
        write_timeout:      WRITE_TIMEOUT,
        open_timeout:       OPEN_TIMEOUT,
        read_timeout:       READ_TIMEOUT,
        gzip:               true,
        gzip_min_size:      GZIP_MIN_SIZE,
        additional_headers: nil
      )
        @body               = body
        @access_token       = access_token
        @faraday_adapter    = faraday_adapter
        @url                = URI.join(base_url, self.class.path).to_s #: String
        @write_timeout      = write_timeout
        @open_timeout       = open_timeout
        @read_timeout       = read_timeout
        @gzip               = gzip
        @gzip_min_size      = gzip_min_size
        @additional_headers = additional_headers
      end

      #: -> Response[ResponseBody]
      def execute
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        faraday_response = begin
          faraday_connection.post do |req|
            req.body = body_to_send
          end
        rescue Faraday::Error => e
          e
        end

        duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
        @response = Response[ResponseBody].new(self.class.response_class, duration.to_f, faraday_response)
      end

      #: -> T::Hash[String, String]
      def headers
        h = BASE_HEADERS
        h = h.merge({ 'Content-Encoding' => 'gzip' }) if compress_body?
        h = h.merge(@additional_headers) if @additional_headers
        h
      end

      # String in the JSON format
      #: -> String
      def raw_body
        @raw_body ||= body.to_json
      end

      # String in the JSON format, compressed with gzip if needed
      #: -> String
      def body_to_send
        return raw_body unless compress_body?

        io = StringIO.new
        Zlib::GzipWriter.wrap(io) { |gz| gz.write(raw_body) }
        io.string
      end

      #: -> bool
      def compress_body?
        return false unless @gzip

        raw_body.bytesize >= @gzip_min_size
      end

      alias body_compressed? compress_body?

      #: -> String?
      def name = self.class.name&.split('::')&.last

      private

      #: -> Faraday::Connection
      def faraday_connection
        Faraday.new(
          @url,
          headers: headers,
          request: {
            write_timeout: @write_timeout,
            open_timeout:  @open_timeout,
            read_timeout:  @read_timeout,
          },
        ) do |conn|
          conn.request :authorization, 'Bearer', @access_token
          conn.adapter @faraday_adapter
        end
      end

    end
  end
end
