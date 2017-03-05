# frozen_string_literal: true
require "coveralls"
Coveralls.wear!

RSpec::Matchers.define_negated_matcher :not_be, :be

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "ragabash"
