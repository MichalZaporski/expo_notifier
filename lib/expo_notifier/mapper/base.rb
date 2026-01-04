# typed: strict
# frozen_string_literal: true

require 'active_support/core_ext/string'
require 'shale'
require 'shale/builder'

module ExpoNotifier
  module Mapper
    # An abstract mapper class.
    # @abstract
    class Base < Shale::Mapper
      include Shale::Builder

      class << self
        alias orig_attribute attribute

        #: (Symbol, *Object, ?as: String?, **Object) ?{ -> void } -> void
        def attribute(name, *args, as: nil, **kwargs, &block)
          json_mapping.finalize! unless json_mapping.finalized?
          T.unsafe(self).orig_attribute(name, *args, **kwargs, &block) # rubocop:disable Sorbet/ForbidTUnsafe
          as ||= name.to_s.camelize(:lower)

          json_mapping.map(as, to: name)
        end
      end

    end
  end
end
