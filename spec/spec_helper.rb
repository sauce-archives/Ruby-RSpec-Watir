# frozen_string_literal: true

require 'watir'
require 'sauce_whisk'
require 'billy/watir/rspec'
Selenium::WebDriver.logger.level = :debug
$DEBUG = true

RSpec.configure do |config|
  config.before(:each) do |example|
    options = platform(example.full_description)
    options[:url] = 'https://ondemand.saucelabs.com:443/wd/hub'

    browser = options.delete(:browser_name)

    # Puffing Billy Local
    @browser = Billy::Browsers::Watir.new :chrome

    # Puffing Billy Remote
    # @browser = Billy::Browsers::Watir.new :chrome, options

    # No Puffing Billy
    #@browser = Watir::Browser.new :chrome #browser, options
  end

  config.after(:each) do |example|
    SauceWhisk::Jobs.change_status(@browser.wd.session_id, !example.exception) if @browser.wd.respond_to?(:session_id)

    @browser.quit
  end

  #
  # Note that having this as a conditional in the test code is less ideal
  # It is better for static data to be pulled from a serialized file like a yaml
  #
  # Note: not all browsers are defaulting to using w3c protocol
  # This will change soon. Where possible prefer the w3c approach
  #
  def platform(name)
    case ENV['PLATFORM']
    when 'windows_10_edge'
      {platform_name: 'Windows 10',
       browser_name: 'edge',
       browser_version: '18.17763'}.merge(sauce_w3c(name))
    when 'windows_8_ie'
      {platform: 'Windows 8.1',
       browser_name: 'ie',
       version: '11.0'}.merge(sauce_w3c(name))
    when 'mac_sierra_chrome'
      # This is for running Chrome with w3c which is not yet the default
      {platform_name: 'macOS 10.12',
       browser_name: 'chrome',
       "goog:chromeOptions": {w3c: true},
       browser_version: '65.0'}.merge(sauce_w3c(name))
    when 'mac_mojave_safari'
      {platform_name: 'macOS 10.14',
       browser_name: 'safari',
       browser_version: '12.0'}.merge(sauce_w3c(name))
    when 'windows_7_ff'
      {platform_name: 'Windows 7',
       browser_name: 'firefox',
       browser_version: '60.0'}.merge(sauce_w3c(name))
    else
      # Always specify a default;
      # this doesn't force Chrome to w3c
      {platform: 'macOS 10.12',
       browser_name: 'chrome',
       tunnel_identifier: 'ORANGE',
       version: '65.0'}.merge(sauce_oss(name))
    end
  end

  def sauce_w3c(name)
    {'sauce:options' => {name: name,
                         build: build_name,
                         username: ENV['SAUCE_USERNAME'],
                         access_key: ENV['SAUCE_ACCESS_KEY'],
                         iedriver_version: '3.141.59',
                         selenium_version: '3.141.59'}}
  end

  def sauce_oss(name)
    {name: name,
     build: build_name,
     username: ENV['SAUCE_USERNAME'],
     access_key: ENV['SAUCE_ACCESS_KEY'],
     selenium_version: '3.141.59'}
  end

  #
  # Note that this build name is specifically for Travis CI execution
  # Most CI tools have ENV variables that can be structured to provide useful build names
  #
  def build_name
    if ENV['TRAVIS_REPO_SLUG']
      "#{ENV['TRAVIS_REPO_SLUG'][%r{[^/]+$}]}: #{ENV['TRAVIS_JOB_NUMBER']}"
    elsif ENV['SAUCE_START_TIME']
      ENV['SAUCE_START_TIME']
    else
      "Ruby-Watir-Selenium: Local-#{Time.now.to_i}"
    end
  end
end
