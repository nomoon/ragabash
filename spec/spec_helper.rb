# frozen_string_literal: true
require "codeclimate-test-reporter"
SimpleCov.start do
  add_filter "vendor"
  add_filter "spec"
  formatter SimpleCov::Formatter::MultiFormatter.new(
    [
      SimpleCov::Formatter::HTMLFormatter,
      CodeClimate::TestReporter::Formatter,
    ]
  )
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "ragabash"
