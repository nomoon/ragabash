# frozen_string_literal: true
require "ice_nine"
require "fast_blank"

module Ragabash
  # A set of useful refinements for base classes.
  #
  # Activate these by including the following in an appropriate lexical scope:
  #   using ::Ragabash
  # or with the pattern:
  #   ::Ragabash::Refinements.activate! || using(::Ragabash::Refinements)
  # for compatibility with versions of Ruby which don't support Refinements.

  module Refinements
    # rubocop:disable Style/Alias

    # @!method deep_freeze
    #   Deep-freezes +self+.
    #
    #   Refines: +::Object+
    #   @return [self]
    #   @see http://www.rubydoc.info/gems/ice_nine/IceNine#deep_freeze-class_method

    # @!method deep_freeze!
    #   Deep-freezes +self+, but skips already-frozen objects.
    #
    #   Refines: +::Object+
    #   @return [self]
    #   @see http://www.rubydoc.info/gems/ice_nine/IceNine#deep_freeze%21-class_method

    # @!method try_dup
    #   Attempts to duplicate +self+, or returns +self+ on non-duplicable objects.
    #
    #   Refines: +::Object+, +::NilClass+, +::FalseClass+, +::TrueClass+, +::Symbol+,
    #   +::Numeric+, +::BigDecimal+
    #   @return [Object,self]

    # @!method deep_dup
    #   Recursively duplicates +self+, including non-duplicable objects where necessary.
    #
    #   Refines: +::Object+, +::NilClass+, +::FalseClass+, +::TrueClass+, +::Symbol+,
    #   +::Numeric+, +::BigDecimal+, +::Array+, +::Hash+, +::Set+
    #   @return [Object,self]

    # @!method safe_copy
    #   Returns +self+ if frozen or otherwise a frozen deep-duplicate.
    #
    #   Refines: +::Object+, +::NilClass+, +::FalseClass+, +::TrueClass+, +::String+,
    #   +::Symbol+, +::Numeric+, +::BigDecimal+, +::Array+, +::Hash+, +::Set+
    #   @return [Object,self]
    # @!parse alias frozen_copy safe_copy

    # @!method blank?
    #   Determines if the object is +(empty? || false)+.
    #   (Uses fast_blank#blank_as? for Strings)
    #
    #   Refines: +::Object+, +::NilClass+, +::FalseClass+, +::TrueClass+, +::String+,
    #   +::Symbol+, +::Numeric+, +::BigDecimal+, +::Array+, +::Hash+, +::Set+
    #   @return [Boolean] +true+ if +(empty? || false)+, otherwise +false+

    # @!method present?
    #   The inverse of {#blank?}
    #
    #   Refines: +::Object+, +::NilClass+, +::FalseClass+, +::TrueClass+, +::String+,
    #   +::Symbol+, +::Numeric+, +::BigDecimal+, +::Array+, +::Hash+, +::Set+
    #   @return [Boolean] +true+ if +!blank?+, othewise +false+

    # This section permits us to fall-back to monkey-patching if we're not on
    # MRI 2.1+
    unless RUBY_ENGINE == "ruby" && RUBY_VERSION >= "2.5"
      @refinement_blocks = {}
      class << self
        private

        def refine(klass, &refinement)
          @refinement_blocks[klass] = refinement
        end
      end
    end

    refine ::Object do
      def deep_freeze
        IceNine.deep_freeze(self)
      end

      def deep_freeze!
        IceNine.deep_freeze!(self)
      end

      def try_dup
        dup
      rescue TypeError
        self
      end
      alias deep_dup try_dup

      def safe_copy
        IceNine.deep_freeze(try_dup)
      end
      alias frozen_copy safe_copy

      def blank?
        puts "blank fallback"
        respond_to?(:empty?) ? !!empty? : !self # rubocop:disable DoubleNegation
      end

      def present?
        puts "present fallback"
        !blank?
      end
    end

    refine ::NilClass do
      def try_dup
        self
      end
      alias deep_dup try_dup
      alias safe_copy try_dup
      alias frozen_copy try_dup

      def blank?
        true
      end

      def present?
        false
      end
    end

    refine ::FalseClass do
      def try_dup
        self
      end
      alias deep_dup try_dup
      alias safe_copy try_dup
      alias frozen_copy try_dup

      def blank?
        true
      end

      def present?
        false
      end
    end

    refine ::TrueClass do
      def try_dup
        self
      end
      alias deep_dup try_dup
      alias safe_copy try_dup
      alias frozen_copy try_dup

      def blank?
        false
      end

      def present?
        true
      end
    end

    refine ::Symbol do
      def try_dup
        self
      end
      alias deep_dup try_dup
      alias safe_copy try_dup
      alias frozen_copy try_dup

      def blank?
        false
      end

      def present?
        true
      end
    end

    refine ::Numeric do
      def try_dup
        self
      end
      alias deep_dup try_dup
      alias safe_copy try_dup
      alias frozen_copy try_dup

      def blank?
        false
      end

      def present?
        true
      end
    end

    # Necessary to re-override Numeric
    require "bigdecimal"
    refine ::BigDecimal do
      alias try_dup dup
      alias deep_dup dup

      def safe_copy
        frozen? ? self : dup.freeze
      end
      alias frozen_copy safe_copy

      def blank?
        false
      end

      def present?
        true
      end
    end

    refine ::String do
      def safe_copy
        frozen? ? self : dup.freeze
      end
      alias frozen_copy safe_copy

      alias blank? blank_as?
      def present?
        !blank_as?
      end
    end

    refine ::Array do
      def deep_dup
        map { |value| value.deep_dup } # rubocop:disable Style/SymbolProc
      end

      def safe_copy
        frozen? ? self : deep_dup.deep_freeze
      end
      alias frozen_copy safe_copy

      alias blank? empty?
      def present?
        !empty?
      end
    end

    refine ::Hash do
      def deep_dup
        hash = dup
        each_pair do |key, value|
          if ::String === key # rubocop:disable Style/CaseEquality
            hash[key] = value.deep_dup
          else
            hash.delete(key)
            hash[key.deep_dup] = value.deep_dup
          end
        end
        hash
      end

      def safe_copy
        frozen? ? self : deep_dup.deep_freeze
      end
      alias frozen_copy safe_copy

      alias blank? empty?
      def present?
        !empty?
      end
    end

    require "set"
    refine ::Set do
      def deep_dup
        set_a = to_a
        set_a.map! do |val|
          next val if ::String === val # rubocop:disable Style/CaseEquality
          val.deep_dup
        end
        self.class.new(set_a)
      end

      def safe_copy
        frozen? ? self : deep_dup.deep_freeze
      end
      alias frozen_copy safe_copy

      alias blank? empty?
      def present?
        !empty?
      end
    end

    REFINEMENT_BLOCKS = IceNine.deep_freeze(@refinement_blocks) || {}
    remove_instance_variable(:@refinement_blocks)
    private_constant :REFINEMENT_BLOCKS

    # Activate the refinements as a monkey-patch if refinements aren't
    # supported. Will only monkey-patch once.
    #
    # This allows for the pattern of:
    #   ::Ragabash::Refinements.activate! || using(::Ragabash::Refinements)
    # Which should work on Ruby versions that do not support refinements.
    #
    # @return [Boolean] +false+ if there is nothing to monkey-patch, or +true+
    #                   if monkey-patching was successful now or before.
    def self.activate!
      return false if REFINEMENT_BLOCKS.empty?
      return true if @activated
      REFINEMENT_BLOCKS.each do |klass, refinement|
        puts klass
        klass.class_eval(&refinement)
      end
      @activated = true
    end
  end
end
