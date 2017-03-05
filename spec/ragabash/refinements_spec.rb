# frozen_string_literal: true
require "spec_helper"

describe Ragabash::Refinements do # rubocop:disable BlockLength
  ::Ragabash::Refinements.activate! || using(::Ragabash::Refinements)

  let(:flt) { 1.15 }

  context "#deep_freeze" do
    it "freezes nested objects" do
      unfrozen_string = String.new("Unfrozen string")
      hash = { first: { second: unfrozen_string } }
      expect(hash.deep_freeze[:first][:second]).to be_frozen
    end
  end

  context "#deep_freeze!" do
    it "freezes nested objects, skipping already-frozen ones" do
      unfrozen_string = String.new("Unfrozen string")
      hash = { first: { second: unfrozen_string }.freeze }
      expect(hash.deep_freeze![:first][:second]).not_to be_frozen
    end
  end

  context "#try_dup" do
    it("NilClass returns self") { expect(nil.try_dup).to equal(nil) }
    it("FalseClass returns self") { expect(false.try_dup).to equal(false) }
    it("TrueClass returns self") { expect(true.try_dup).to equal(true) }
    it("Integer returns self") { expect(1.try_dup).to equal(1) }
    it("Float returns self") { expect(flt.try_dup).to equal(flt) }
    it("Symbol returns self") { expect(:symbol.try_dup).to equal(:symbol) }
    it("BigDecimal duplicates") { expect(BigDecimal.new("1.5").try_dup).to not_equal(BigDecimal.new("1.5")) }
    it("String duplicates") { expect("A string".try_dup).to not_equal("A string") }
    it("Array duplicates") { expect([1, 2, 3].try_dup).to not_equal([1, 2, 3]) }
    it("Hash duplicates") { expect({ a: 1, b: 2 }.try_dup).to not_equal(a: 1, b: 2) }
    it("Set duplicates") { expect(Set.new([1, 2]).try_dup).to not_equal(Set.new([1, 2])) }
  end

  context "#deep_dup" do
    it("NilClass returns self") { expect(nil.deep_dup).to equal(nil) }
    it("FalseClass returns self") { expect(false.deep_dup).to equal(false) }
    it("TrueClass returns self") { expect(true.deep_dup).to equal(true) }
    it("Integer returns self") { expect(1.deep_dup).to equal(1) }
    it("Float returns self") { expect(flt.deep_dup).to equal(flt) }
    it("Symbol returns self") { expect(:symbol.deep_dup).to equal(:symbol) }
    it("BigDecimal duplicates") { expect(BigDecimal.new("1.5").try_dup).to not_equal(BigDecimal.new("1.5")) }
    it("String duplicates") { expect("A string".deep_dup).to not_equal("A string") }
    it("Array duplicates deeply") do
      element = [String.new("A string")]
      array = [element]
      expect(array.deep_dup[0][0]).to not_equal(element[0]).and eq(element[0])
    end
    it("Hash duplicates deeply") do
      element = { "first" => String.new("A string") }
      hash = { first: element }
      expect(hash.deep_dup[:first]["first"]).to not_equal(element["first"])
        .and eq(element["first"])
    end
    it("Set duplicates deeply") do
      element = [BigDecimal.new("1.5")]
      set = Set.new([element])
      expect(set.deep_dup.to_a.first).to not_equal(element).and eq(element)
    end
  end

  context "#safe_copy" do # rubocop:disable BlockLength
    it("NilClass returns self") { expect(nil.safe_copy).to equal(nil) }
    it("FalseClass returns self") { expect(false.safe_copy).to equal(false) }
    it("TrueClass returns self") { expect(true.safe_copy).to equal(true) }
    it("Integer returns self") { expect(1.safe_copy).to equal(1) }
    it("Float returns self") { expect(flt.safe_copy).to equal(flt) }
    it("Symbol returns self") { expect(:symbol.safe_copy).to equal(:symbol) }
    it("BigDecimal duplicates and freeze") do
      expect(BigDecimal.new("1.5").safe_copy).to not_equal(BigDecimal.new("1.5"))
        .and eq(BigDecimal.new("1.5")).and be_frozen
    end
    it("Frozen string returns self") do
      frozen_string = String.new("A string").freeze
      expect(frozen_string.safe_copy).to equal(frozen_string).and be_frozen
    end
    it("String duplicates and freeze") do
      unfrozen_string = String.new("A string")
      expect(unfrozen_string.safe_copy).to not_equal(unfrozen_string)
        .and eq(unfrozen_string).and be_frozen
    end
    it("Array duplicates and freezes") do
      expect([1, 2, 3].safe_copy).to not_equal([1, 2, 3]).and eq([1, 2, 3])
        .and be_frozen
    end
    it("Hash duplicates and freezes") do
      expect({ a: 1, b: 2 }.safe_copy).to not_equal(a: 1, b: 2).and eq(a: 1, b: 2)
        .and be_frozen
    end
    it("Set duplicates and freezes") do
      expect(Set.new([1, 2]).safe_copy).to not_equal(Set.new([1, 2]))
        .and eq(Set.new([1, 2])).and be_frozen
    end
    it("Object duplicates and freezes") do
      struct = Struct.new("Test")
      object = struct.new
      expect(object.safe_copy).to not_equal(object).and eq(object).and be_frozen
    end
  end

  context "#blank?" do
    it("Object returns false") { expect(Object.new.blank?).to equal(false) }
    it("NilClass returns true") { expect(nil.blank?).to equal(true) }
    it("FalseClass returns true") { expect(false.blank?).to equal(true) }
    it("TrueClass returns false") { expect(true.blank?).to equal(false) }
    it("Integer returns false") { expect(1.blank?).to equal(false) }
    it("Float returns false") { expect(flt.blank?).to equal(false) }
    it("Symbol returns false") { expect(:symbol.blank?).to equal(false) }
    it("BigDecimal returns false") { expect(BigDecimal.new("1.5").blank?).to equal(false) }
    it("String returns true if empty") { expect("".blank?).to equal(true) }
    it("String returns true if unicode whitespace") { expect("\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u202F\u205F\u3000".blank?).to equal(true) }
    it("String returns true if regular whitespace") { expect("          ".blank?).to equal(true) }
    it("String returns false if not empty") { expect("A string".blank?).to equal(false) }
    it("Array returns true if empty") { expect([].blank?).to equal(true) }
    it("Array returns false if not empty") { expect([1].blank?).to equal(false) }
    it("Hash returns true if empty") { expect({}.blank?).to equal(true) }
    it("Hash returns false if not empty") { expect({ a: 1 }.blank?).to equal(false) }
    it("Set returns true if empty") { expect(Set.new.blank?).to equal(true) }
    it("Set returns false if not empty") { expect(Set.new([1, 2]).blank?).to equal(false) }
  end

  context "#present?" do
    it("Object returns true") { expect(Object.new.present?).to equal(true) }
    it("NilClass returns false") { expect(nil.present?).to equal(false) }
    it("FalseClass returns false") { expect(false.present?).to equal(false) }
    it("TrueClass returns true") { expect(true.present?).to equal(true) }
    it("Integer returns true") { expect(1.present?).to equal(true) }
    it("Float returns true") { expect(flt.present?).to equal(true) }
    it("Symbol returns true") { expect(:symbol.present?).to equal(true) }
    it("BigDecimal returns true") { expect(BigDecimal.new("1.5").present?).to equal(true) }
    it("String returns false if empty") { expect("".present?).to equal(false) }
    it("String returns false if unicode whitespace") { expect("\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u202F\u205F\u3000".present?).to equal(false) }
    it("String returns false if regular whitespace") { expect("          ".present?).to equal(false) }
    it("String returns true if not empty") { expect("A string".present?).to equal(true) }
    it("Array returns false if empty") { expect([].present?).to equal(false) }
    it("Array returns true if not empty") { expect([1].present?).to equal(true) }
    it("Hash returns false if empty") { expect({}.present?).to equal(false) }
    it("Hash returns true if not empty") { expect({ a: 1 }.present?).to equal(true) }
    it("Set returns false if empty") { expect(Set.new.present?).to equal(false) }
    it("Set returns true if not empty") { expect(Set.new([1, 2]).present?).to equal(true) }
  end
end
