# frozen_string_literal: true
require "ice_nine"

module Ragabash
  module Refinements
    # rubocop:disable Style/Alias
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
    end

    refine ::NilClass do
      def try_dup
        self
      end
      alias deep_dup try_dup
      alias safe_copy try_dup
      alias frozen_copy try_dup
    end

    refine ::FalseClass do
      def try_dup
        self
      end
      alias deep_dup try_dup
      alias safe_copy try_dup
      alias frozen_copy try_dup
    end

    refine ::TrueClass do
      def try_dup
        self
      end
      alias deep_dup try_dup
      alias safe_copy try_dup
      alias frozen_copy try_dup
    end

    refine ::Symbol do
      def try_dup
        self
      end
      alias deep_dup try_dup
      alias safe_copy try_dup
      alias frozen_copy try_dup
    end

    refine ::Numeric do
      def try_dup
        self
      end
      alias deep_dup try_dup
      alias safe_copy try_dup
      alias frozen_copy try_dup
    end

    # Necessary to re-override Numeric
    require "bigdecimal"
    refine ::BigDecimal do
      def try_dup
        dup
      end
      alias deep_dup try_dup

      def safe_copy
        frozen? ? self : dup.freeze
      end
      alias frozen_copy safe_copy
    end

    refine ::String do
      def safe_copy
        frozen? ? self : dup.freeze
      end
      alias frozen_copy safe_copy
    end

    refine ::Array do
      def deep_dup
        map { |value| value.deep_dup } # rubocop:disable Style/SymbolProc
      end

      def safe_copy
        frozen? ? self : deep_dup.deep_freeze
      end
      alias frozen_copy safe_copy
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
    end

    refine ::Set do
      def deep_dup
        set_a = to_a
        set_a.map! do |val|
          next val if ::String === val # rubocop:disable Style/CaseEquality
          val.deep_dup
        end
        self.class[set_a]
      end

      def safe_copy
        frozen? ? self : deep_dup.deep_freeze
      end
      alias frozen_copy safe_copy
    end
  end
end
