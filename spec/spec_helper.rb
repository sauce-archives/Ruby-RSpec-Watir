# frozen_string_literal: true

require 'watir'
require 'simple_sauce'

RSpec.configure do |config|
  config.before(:each) do |example|
    opts = platform.merge(name: example.full_description,
                          command_timeout: 90)
    sauce_options = SimpleSauce::Options.new(opts)

    @session = SimpleSauce::Session.new(sauce_options)
    @session.data_center = ENV['SAUCE_DATA_CENTER'].to_sym if ENV['SAUCE_DATA_CENTER']

    @browser = Watir::Browser.new(@session.start)
  end

  config.after(:each) do |example|
    @session.stop(!example.exception)
  end

  #
  # Note that having this as a conditional in the test code is less ideal
  # It is better for static data to be pulled from a serialized file like a yaml
  #
  # Note: not all browsers are defaulting to using w3c protocol
  # This will change soon. Where possible prefer the w3c approach
  #
  def platform
    ENV['PLATFORM'] ||= 'mac_sierra_chrome'

    case ENV['PLATFORM']
    when 'windows_10_edge'
      {platform_name: 'Windows 10',
       browser_name: 'MicrosoftEdge'}
    when 'windows_8_ie'
      {platform_name: 'Windows 8.1',
       browser_name: 'internet explorer'}
    when 'mac_sierra_chrome'
      {platform_name: 'macOS 10.12',
       browser_name: 'chrome'}
    when 'mac_mojave_safari'
      {platform_name: 'macOS 10.14',
       browser_name: 'safari'}
    when 'windows_7_ff'
      {platform_name: 'Windows 7',
       browser_name: 'firefox'}
    when 'headless'
      ENV['SAUCE_DATA_CENTER'] = 'US_EAST'
      {platform_name: 'Linux',
       browser_name: 'chrome'}
    end
  end
end
