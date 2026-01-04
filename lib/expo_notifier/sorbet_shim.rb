# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'

begin
  T::Configuration.default_checked_level = :never
rescue StandardError
  puts 'WARN: Sorbet default checked level could not be set!'
end
error_handler = ->(error, *_) do
end
# Suppresses errors caused by incorrect parameter and return types
T::Configuration.call_validation_error_handler = error_handler
# Suppresses errors caused by T.cast, T.let, T.must, etc.
T::Configuration.inline_type_error_handler = error_handler
# Suppresses errors caused by incorrect parameter ordering
T::Configuration.sig_validation_error_handler = error_handler
