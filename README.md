[![Ruby](https://github.com/MichalZaporski/expo_notifier/actions/workflows/main.yml/badge.svg)](https://github.com/MichalZaporski/expo_notifier/actions/workflows/main.yml)

# ExpoNotifier

A Ruby client for the Expo Push Notifications API, providing typed request/response objects, automatic payload mapping, error classification, and configurable HTTP behavior. It is built on Faraday for HTTP communication.

The library currently supports:

- Sending push notifications

- Fetching push notification receipts

- Validating Expo push tokens

More information about the Expo API you can [find here.](https://docs.expo.dev/push-notifications/sending-notifications/)

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add expo_notifier
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install expo_notifier
```

## Usage

### SendPushNotifications

#### Example

```ruby
params = ExpoNotifier::Mapper::PushMessages.build do |msgs|
  msgs.push_message do |msg|
    msg.to    = ['ExponentPushToken[xxxxxxxx]']
    msg.title = 'Title'
    msg.body  = 'Body'
    msg.data  = { order_id: 123 }
  end
  msgs.push_message do |msg|
    msg.to    = ['ExponentPushToken[xxxxxxxx]']
    msg.title = 'Title'
    msg.body  = 'Second msg'
  end
end

request = ExpoNotifier::Request::SendPushNotifications.new(params)
response = request.execute
if response.success?
  response.body.data.each do |ticket|
    puts "Notification status: #{ticket.status}, id: #{ticket.id}"
  end
end
```

#### Available message parameters

| Parameter            | Type            |
| -------------------- | --------------- |
| `to`                 | `Array[String]` |
| `title`              | `String`        |
| `body`               | `String`        |
| `data`               | `Hash`          |
| `content_available`  | `Boolean`       |
| `ttl`                | `Integer`       |
| `expiration`         | `Integer`       |
| `priority`           | `String`        |
| `subtitle`           | `String`        |
| `sound`              | `String`        |
| `badge`              | `Integer`       |
| `interruption_level` | `String`        |
| `channel_id`         | `String`        |
| `icon`               | `String`        |
| `category_id`        | `String`        |
| `mutable_content`    | `Boolean`       |
| `rich_content.image` | `String`        |


### GetPushNotificationReceipts

#### Example

``` ruby
params = ExpoNotifier::Mapper::PushReceiptIds.new(
  ids: ['receipt-id-1', 'receipt-id-2'],
)

request = ExpoNotifier::Request::GetPushNotificationReceipts.new(params)
response = request.execute
if response.success?
  response.body.data.each do |receipt_id, receipt|
    puts "Receipt #{receipt_id}: status=#{receipt.status}, message=#{receipt.message}"
  end
end
```

### Request configuration

Each request accepts optional configuration parameters that control HTTP behavior.

#### Available options

```ruby
access_token:       String   # Adds Authorization: Bearer <token>
faraday_adapter:    Symbol   # Default: your default Faraday adapter
base_url:           String   # API base URL, default: https://exp.host
write_timeout:      Integer  # Write timeout in seconds, default: 5
open_timeout:       Integer  # Open timeout in seconds, default: 5
read_timeout:       Integer  # Read timeout in seconds, default: 30
gzip:               Boolean  # Enable gzip compression, default: true
gzip_min_size:      Integer  # Minimum request body size to enable gzip, default: 1024 bytes
additional_headers: Hash     # Your additional headers
```

#### Example

```ruby
request = ExpoNotifier::Request::SendPushNotifications.new(
  params,
  access_token: 'secret-token',
  base_url: 'https://example.test',
  gzip_min_size: 512,
  additional_headers: {
    'X-Custom-Header' => 'custom',
  },
)
```

### Response Handling

All requests return a Response object exposing:

```ruby
response.status_code
response.duration
response.headers
response.body

response.success?                   # 200
response.malformed_request_error?   # 400
response.too_many_requests_error?   # 429
response.server_error?              # 5xx
response.communication_error?       # HTTP communication error
response.communication_error_message
```

### Expo push token validation

The library provides a helper for validating Expo push tokens before sending requests. Usage:

```ruby
ExpoNotifier.expo_push_token?('ExponentPushToken[abcdef123456]')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/MichalZaporski/expo_notifier.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
