# frozen_string_literal: true
require "awesome_print"
require "ragabash"

AwesomePrint::Formatter.send(:include, ::Ragabash::AwesomeStringFormatter)
