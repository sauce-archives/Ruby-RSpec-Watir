require_relative "spec_helper"

describe "Guinea Pig Link" do
  it "Verify Link opens page with correct title" do
    @browser.goto "https://saucelabs-sample-test-frameworks.github.io/training-test-page/"
    @browser.a(id: 'i_am_a_link').click

    expect(@browser.title).not_to eq "I am a page title - Sauce Labs"
  end
end
