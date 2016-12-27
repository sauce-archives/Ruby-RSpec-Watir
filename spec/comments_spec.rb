require_relative "spec_helper"

describe "Guinea Pig Comments" do
  it "Verify comments text" do
    @browser.goto "https://saucelabs-sample-test-frameworks.github.io/training-test-page/"

    text = "This is a comment"
    @browser.textarea(id: 'comments').set text
    @browser.button(id: 'submit').click

    comment = @browser.span(id: 'your_comments').text[/^Your comments: (.*)/, 1]

    expect(comment).to eq text
  end
end
