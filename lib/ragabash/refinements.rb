# frozen_string_literal: true
require "ice_nine"

module Ragabash
  # A set of useful refinements for base classes.
  #
  # Activate these by including the following in an appropriate
  # lexical scope:
  #   using Ragabash::Refinements
  # If your Ruby version does not support refinements, this will fall back to
  # monkey-patching.
  #
  # You may also explicitly activate these refinements via monkey-patching with:
  #   Ragabash::Refinements.monkey_patch! # or
  #   Ragabash::Refinements.activate!
  #

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

    MUTEX = Mutex.new
    private_constant :MUTEX

    @rmods = []
    @rmods_activated = []

    class << self
      # Activate the refinements as permanent monkey-patches.
      #
      # @return [Array<Class>] a list of all patched classes.
      def monkey_patch!
        return @rmods_activated.dup if @rmods.empty?
        MUTEX.synchronize do
          @rmods.delete_if do |mod|
            if mod.is_a?(Array)
              klass = mod[0]
              klass.class_eval(&mod[1])
              @rmods_activated << klass
            elsif mod.is_a?(Module)
              klass = mod.ancestors[1]
              mod.public_instance_methods(false).each do |m_name|
                umeth = mod.public_instance_method(m_name)
                klass.send(:define_method, umeth.name, umeth)
              end
              @rmods_activated << klass
            end
          end
        end
        @rmods_activated.dup
      end

      alias activate! monkey_patch!
    end

    #
    # Fake refinements for Rubies that need them.
    #
    unless ::Module.private_method_defined?(:using)
      class << self
        private

        def refine(klass, &block)
          @rmods << [klass, block]
          self
        end
      end

      # @!visibility private
      class ::Module # rubocop:disable ClassAndModuleChildren
        # @!visibility private
        def using(klass)
          if klass == ::Ragabash::Refinements
            return ::Ragabash::Refinements.monkey_patch!
          end
          super
        end
      end
    end

    ##
    # The various refinements
    ##

    @rmods << refine(::Object) do
      def deep_freeze
        IceNine.deep_freeze(self)
      end

      def deep_freeze!
        IceNine.deep_freeze!(self)
      end

      def try_dup
        respond_to?(:dup) ? dup : self
      end
      alias deep_dup try_dup

      def safe_copy
        IceNine.deep_freeze(try_dup)
      end
      alias frozen_copy safe_copy

      def blank?
        respond_to?(:empty?) ? !!empty? : !self # rubocop:disable DoubleNegation
      end

      def present?
        !blank?
      end
    end

    @rmods << refine(::NilClass) do
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

    @rmods << refine(::FalseClass) do
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

    @rmods << refine(::TrueClass) do
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

    @rmods << refine(::Symbol) do
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

    @rmods << refine(::Numeric) do
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

    require "bigdecimal"
    @rmods << refine(::BigDecimal) do
      def dup
        dup = self.class.allocate
        initialize_copy(dup)
        dup
      end
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

    @rmods << refine(::String) do
      def safe_copy
        frozen? ? self : dup.freeze
      end
      alias frozen_copy safe_copy

      if defined?(JRUBY_VERSION)
        BLANK_RE = /\A[[:space:]]*\z/
        def blank?
          empty? || BLANK_RE === self # rubocop:disable Style/CaseEquality
        end
      else
        require "fast_blank"
        alias blank? blank_as?
      end

      def present?
        !blank?
      end
    end

    @rmods << refine(::Array) do
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

    @rmods << refine(::Hash) do
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
    @rmods << refine(::Set) do
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
  end
end
