# typed: strict
# frozen_string_literal: true

module ExpoNotifier
  class Response
    extend T::Generic

    Body = type_member(:out) { { upper: Mapper::Base } }

    #: Integer?
    attr_reader :status_code

    #: Hash[(String | Symbol), String]?
    attr_reader :headers

    #: String?
    attr_reader :raw_body

    #: Float
    attr_reader :duration

    #: Faraday::Error?
    attr_reader :communication_error

    #: (singleton(Mapper::Base), Float, (Faraday::Response | Faraday::Error)) -> void
    def initialize(body_class, duration, faraday_response)
      if faraday_response.is_a?(Faraday::Response)
        initialize_with_faraday_response(faraday_response)
      elsif faraday_response.is_a?(Faraday::Error)
        @communication_error = faraday_response #: Faraday::Error?
      end
      @body_class = body_class
      @duration   = duration
    end

    # Response body mapped to Ruby objects.
    #: -> Body?
    def body
      @body ||= parse_response_body #: Body?
    end

    #: -> String?
    def communication_error_message
      return unless communication_error

      "[#{communication_error.class}] => #{T.must(communication_error).message}"
    end

    #: -> bool
    def success?
      @status_code == 200
    end

    #: -> bool
    def too_many_requests_error?
      @status_code == 429
    end

    #: -> bool
    def malformed_request_error?
      @status_code.to_s.start_with?('4') && !too_many_requests_error?
    end

    #: -> bool
    def server_error?
      @status_code.to_s.start_with?('5')
    end

    #: -> bool
    def communication_error?
      !!communication_error
    end

    private

    #: (Faraday::Response) -> void
    def initialize_with_faraday_response(faraday_response)
      @status_code = faraday_response.status  #: Integer?
      @headers     = faraday_response.headers #: Hash[(String | Symbol), String]?
      @raw_body    = faraday_response.body    #: String?
    end

    #: -> Body?
    def parse_response_body
      return unless @raw_body

      @body_class.from_json(@raw_body)
    rescue Shale::ParseError, JSON::ParserError
      nil
    end

  end
end
