# frozen_string_literal: true
require "simplecov"
require "coveralls"

formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter,
]
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(formatters)
SimpleCov.start

RSpec::Matchers.define_negated_matcher :not_be, :be

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "ragabash"
