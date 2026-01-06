# typed: true
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'expo_notifier'
require 'debug'
require 'minitest/autorun'
require 'shoulda-context'
require 'vcr'
require 'webmock/minitest'

VCR.configure do |c|
  c.default_cassette_options = {
    match_requests_on: %i[method path],
    record:            :once,
    serialize_with:    :yaml,
  }
  c.hook_into :webmock
  c.cassette_library_dir = 'test/cassettes'
  c.allow_http_connections_when_no_cassette = true
end

class TestCase < Minitest::Test
  #: [R] (Symbol, String, Class) { -> R } -> R
  def stub_request_and_raise(method, url, error_class, &block)
    stub = stub_request(method, url).and_raise(error_class)
    val = block.call
    remove_request_stub(stub)

    val
  end

  #: [R] (?Hash[Symbol, untyped]) { -> R } -> R
  def cassette(options = {}, &block)
    VCR.use_cassette(cassette_name, options, &block)
  end

  private

  #: -> String
  def cassette_name
    [
      *module_path(self),
      name_of_test,
    ].map { |el| to_snakecase(el) }
      .join('/')
  end

  #: (Object) -> Array[String]
  def module_path(object)
    klass = object.is_a?(::Module) ? object : object.class
    klass.to_s.split('::')
  end

  #: -> String
  def name_of_test
    name_of_class = T.must(self.class.name).delete_suffix('Test')
    name.to_s.delete_prefix("test_: #{name_of_class}").delete_suffix('. ').strip
  end

  #: (String) -> String
  def to_snakecase(string)
    string.gsub(/([^A-Z])([A-Z]+)/, '\1_\2').downcase
  end
end
