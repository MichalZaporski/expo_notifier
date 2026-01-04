# typed: strict
# frozen_string_literal: true

require_relative 'base'

module ExpoNotifier
  module Mapper
    class RichContent < Base
      attribute :image, Shale::Type::String, doc: <<~DOC
        Android and iOS

        The image URL. Android will show the image out of the box. On iOS, you need to add a Notification Service Extension
        target to your app. See this example on how to do that.
      DOC
    end
  end
end
