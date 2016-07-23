# frozen_string_literal: true
require "rouge"

module Ragabash
  module AwesomeStringFormatter
    def self.included(base)
      base.send :alias_method, :cast_without_string, :cast
      base.send :alias_method, :cast, :cast_with_string
    end

    def cast_with_string(object, type)
      object.is_a?(::String) ? :string : cast_without_string(object, type)
    end

    MULTILINE_UNESCAPES = {
      "\\t" => "\t",
      "\\n" => "\n",
      "\\r\\n" => "\n",
      '\\"' => '"',
    }.freeze
    R_FORMATTER = ::Rouge::Formatters::Terminal256.new
    R_LEXERS = ::Rouge::Lexer.all
    private_constant :MULTILINE_UNESCAPES, :R_FORMATTER, :R_LEXERS

    def awesome_string(string)
      lexers = ::Rouge::Guessers::Source.new(string).filter(R_LEXERS)
      if !lexers.empty?
        format_syntax_string(string, lexers.first)
      elsif string =~ /(?:\r?\n)(?!\z)/
        format_multiline_string(string)
      else
        format_plain_string(string)
      end
    end

    private

    def format_syntax_string(string, lexer)
      label = heredoc_label(lexer.name.gsub(/^.*::/, ""))
      string = R_FORMATTER.format(lexer.lex(string))
      "<<#{label}\n#{string}\n#{label}"
    end

    def format_multiline_string(string)
      string = string.inspect[1..-2]
      string.gsub!(/\\r\\n|\\[tn"]/, MULTILINE_UNESCAPES)
      colorize_string_with_escapes!(string)
      label = heredoc_label("String")
      %(<<#{label}\n#{string}\n#{label})
    end

    def format_plain_string(string)
      string = string.inspect[1..-2]
      colorize_string_with_escapes!(string)
      %("#{string}")
    end

    def heredoc_label(name)
      %(#{colorize('__"', :keyword)}#{colorize(name, :class)}#{colorize('"__', :keyword)})
    end

    def colorize_string_with_escapes!(string)
      string.gsub!(/[^\\]+|\\./) do |m|
        colorize(m, m.start_with?("\\") ? :symbol : :string)
      end
    end
  end
end
