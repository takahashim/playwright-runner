# frozen_string_literal: true

require_relative 'lib/playwrightrunner/version'

Gem::Specification.new do |spec|
  spec.name          = 'playwright-runner'
  spec.version       = PlaywrightRunner::VERSION
  spec.authors       = ['Kenshi Muto']
  spec.email         = ['kmuto@kmuto.jp']

  spec.summary       = 'Playwright Runner'
  spec.description   = 'Provide useful methods to run Playwright, intended to be used with Re:VIEW'
  spec.homepage      = 'https://github.com/kmuto/playwright-runner'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/kmuto/playwright-runner'
  spec.metadata['changelog_uri'] = 'https://github.com/kmuto/playwright-runner/commits/main'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'playwright-ruby-client', '>= 1.28.0'
end
