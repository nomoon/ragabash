# frozen_string_literal: true
require "pry"
require "ragabash/ext/awesome_strings"

Pry.config.print = proc do |output, value|
  Pry::Helpers::BaseHelpers.stagger_output("=> #{value.ai}", output)
end
