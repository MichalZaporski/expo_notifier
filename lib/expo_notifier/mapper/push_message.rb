# typed: strict
# frozen_string_literal: true

require_relative 'base'
require_relative 'rich_content'

module ExpoNotifier
  module Mapper
    class PushMessage < Base
      attribute :to, Shale::Type::String, collection: true, doc: <<~DOC
        Android and iOS

        An array of Expo push tokens specifying the recipient(s) of this message.
      DOC

      attribute :content_available, Shale::Type::Boolean, as: '_contentAvailable', doc: <<~DOC
        iOS Only

        When this is set to true, the notification will cause the iOS app to start in the background to
        run a background task. Your app needs to be configured to support this.
      DOC

      attribute :data, Shale::Type::Value, doc: <<~DOC
        Android and iOS

        A JSON object delivered to your app.It may be up to about 4KiB; the total notification payload
        sent to Apple and Google must be at most 4KiB or else you will get a "Message Too Big" error.
      DOC

      attribute :title, Shale::Type::String, doc: <<~DOC
        Android and iOS

        The title to display in the notification. Often displayed above the notification body.
        Maps to `AndroidNotification.title` and `aps.alert.title`.
      DOC

      attribute :body, Shale::Type::String, doc: <<~DOC
        Android and iOS

        The message to display in the notification. Maps to `AndroidNotification.body` and `aps.alert.body`.
      DOC

      attribute :ttl, Shale::Type::Integer, doc: <<~DOC
        Android and iOS

        Time to Live: the number of seconds for which the message may be kept around for redelivery if
        it hasn't been delivered yet. Defaults to undefined to use the respective defaults of each
        provider (1 month for Android/FCM as well as iOS/APNs).
      DOC

      attribute :expiration, Shale::Type::Integer, doc: <<~DOC
        Android and iOS

        Timestamp since the Unix epoch specifying when the message expires.
        Same effect as `ttl` (`ttl` takes precedence over `expiration`).
      DOC

      attribute :priority, Shale::Type::String, doc: <<~DOC
        Android and iOS

        Accepted values: 'default' | 'normal' | 'high'

        The delivery priority of the message. Specify default or omit this field to use the default priority
        on each platform ("normal" on Android and "high" on iOS).
      DOC

      attribute :subtitle, Shale::Type::String, doc: <<~DOC
        iOS Only

        The subtitle to display in the notification below the title. Maps to `aps.alert.subtitle`.
      DOC

      attribute :sound, Shale::Type::String, doc: <<~DOC
        iOS Only

        Play a sound when the recipient receives this notification. Specify default to play the device's
        default notification sound, or omit this field to play no sound. Custom sounds need to be configured
        via the config plugin and then specified including the file extension. Example: bells_sound.wav.
      DOC

      attribute :badge, Shale::Type::Integer, doc: <<~DOC
        iOS Only

        Number to display in the badge on the app icon. Specify zero to clear the badge.
      DOC

      attribute :interruption_level, Shale::Type::String, doc: <<~DOC
        iOS Only

        Accepted values: 'active' | 'critical' | 'passive' | 'time-sensitive'

        The importance and delivery timing of a notification. The string values correspond to the
        `UNNotificationInterruptionLevel` enumeration cases.
      DOC

      attribute :channel_id, Shale::Type::String, doc: <<~DOC
        Android Only

        ID of the Notification Channel through which to display this notification. If an ID is specified but
        the corresponding channel does not exist on the device (that has not yet been created by your app),
        the notification will not be displayed to the user.
      DOC

      attribute :icon, Shale::Type::String, doc: <<~DOC
        Android Only

        The notification's icon. Name of an Android drawable resource (example: my_icon).
        Defaults to the icon specified in the config plugin.
      DOC

      attribute :rich_content, RichContent, doc: <<~DOC
        Android and iOS

        Currently supports setting a notification image. Provide an object with key image and value of
        type string, which is the image URL. Android will show the image out of the box. On iOS, you need to add
        a Notification Service Extension target to your app.
      DOC

      attribute :category_id, Shale::Type::String, doc: <<~DOC
        Android and iOS

        ID of the notification category that this notification is associated with.
      DOC

      attribute :mutable_content, Shale::Type::Boolean, doc: <<~DOC
        iOS Only

        Specifies whether this notification can be intercepted by the client app. Defaults to false.
      DOC
    end
  end
end
