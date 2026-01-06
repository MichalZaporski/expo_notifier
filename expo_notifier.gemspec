# frozen_string_literal: true

require_relative 'lib/expo_notifier/version'

Gem::Specification.new do |spec|
  spec.name = 'expo_notifier'
  spec.version = ExpoNotifier::VERSION
  spec.authors = ['Michał Zaporski']
  spec.email = ['focus16k@gmail.com']

  spec.summary = 'A Ruby gem for sending Expo push notifications, built on Faraday.'
  spec.description = <<~DESC
    A Ruby client for the Expo Push Notifications API, providing typed request/response objects,
    automatic payload mapping, error classification, and configurable HTTP behavior.
    It is built on Faraday for HTTP communication.
  DESC
  spec.homepage = 'https://github.com/MichalZaporski/expo_notifier'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/MichalZaporski/expo_notifier'
  spec.metadata['changelog_uri'] = 'https://github.com/MichalZaporski/expo_notifier/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 6.0'
  spec.add_dependency 'faraday', '~> 2.0'
  spec.add_dependency 'shale', '~> 1.2'
  spec.add_dependency 'shale-builder', '~> 0.8'
  spec.add_dependency 'sorbet-runtime', '>= 0.5'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
