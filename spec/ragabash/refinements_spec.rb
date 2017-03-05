# frozen_string_literal: true
require "spec_helper"

describe Ragabash::Refinements do # rubocop:disable BlockLength
  using ::Ragabash::Refinements

  let(:flt) { 1.15 }
  let(:big) { BigDecimal.new("1.5") }
  let(:ary) { [1, 2, 3] }
  let(:hsh) { { a: 1, b: 2 } }
  let(:set) { Set.new([1, 2]) }

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
    it("NilClass returns self") { expect(nil.try_dup).to be(nil) }
    it("FalseClass returns self") { expect(false.try_dup).to be(false) }
    it("TrueClass returns self") { expect(true.try_dup).to be(true) }
    it("Integer returns self") { expect(1.try_dup).to be(1) }
    it("Float returns self") { expect(flt.try_dup).to be(flt) }
    it("Symbol returns self") { expect(:symbol.try_dup).to be(:symbol) }
    it("BigDecimal duplicates") { expect(big.try_dup).to not_be(big) }
    it("String duplicates") { expect("A string".try_dup).to not_be("A string") }
    it("Array duplicates") { expect(ary.try_dup).to not_be(ary) }
    it("Hash duplicates") { expect(hsh.try_dup).to not_be(hsh) }
    it("Set duplicates") { expect(set.try_dup).to not_be(set) }
  end

  context "#deep_dup" do
    it("NilClass returns self") { expect(nil.deep_dup).to be(nil) }
    it("FalseClass returns self") { expect(false.deep_dup).to be(false) }
    it("TrueClass returns self") { expect(true.deep_dup).to be(true) }
    it("Integer returns self") { expect(1.deep_dup).to be(1) }
    it("Float returns self") { expect(flt.deep_dup).to be(flt) }
    it("Symbol returns self") { expect(:symbol.deep_dup).to be(:symbol) }
    it("BigDecimal duplicates") { expect(big.deep_dup).to not_be(big) }
    it("String duplicates") { expect("A string".deep_dup).to not_be("A string") }
    it("Array duplicates deeply") do
      element = [String.new("A string")]
      array = [element]
      expect(array.deep_dup[0][0]).to not_be(element[0]).and eq(element[0])
    end
    it("Hash duplicates deeply") do
      element = { "first" => String.new("A string") }
      hash = { first: element }
      expect(hash.deep_dup[:first]["first"]).to not_be(element["first"])
        .and eq(element["first"])
    end
    it("Set duplicates deeply") do
      element = [big]
      set = Set.new([element])
      expect(set.deep_dup.to_a.first).to not_be(element).and eq(element)
    end
  end

  context "#safe_copy" do # rubocop:disable BlockLength
    it("NilClass returns self") { expect(nil.safe_copy).to be(nil) }
    it("FalseClass returns self") { expect(false.safe_copy).to be(false) }
    it("TrueClass returns self") { expect(true.safe_copy).to be(true) }
    it("Integer returns self") { expect(1.safe_copy).to be(1) }
    it("Float returns self") { expect(flt.safe_copy).to be(flt) }
    it("Symbol returns self") { expect(:symbol.safe_copy).to be(:symbol) }
    it("BigDecimal duplicates and freeze") do
      expect(big.safe_copy).to not_be(big)
        .and eq(big).and be_frozen
    end
    it("Frozen string returns self") do
      frozen_string = String.new("A string").freeze
      expect(frozen_string.safe_copy).to be(frozen_string).and be_frozen
    end
    it("String duplicates and freeze") do
      unfrozen_string = String.new("A string")
      expect(unfrozen_string.safe_copy).to not_be(unfrozen_string)
        .and eq(unfrozen_string).and be_frozen
    end
    it("Array duplicates and freezes") do
      expect(ary.safe_copy).to not_be(ary).and eq(ary)
        .and be_frozen
    end
    it("Hash duplicates and freezes") do
      expect(hsh.safe_copy).to not_be(hsh).and eq(hsh)
        .and be_frozen
    end
    it("Set duplicates and freezes") do
      expect(set.safe_copy).to not_be(set)
        .and eq(set).and be_frozen
    end
    it("Object duplicates and freezes") do
      struct = Struct.new("Test")
      object = struct.new
      expect(object.safe_copy).to not_be(object).and eq(object).and be_frozen
    end
  end

  context "#blank?" do
    it("Object returns false") { expect(Object.new.blank?).to be(false) }
    it("NilClass returns true") { expect(nil.blank?).to be(true) }
    it("FalseClass returns true") { expect(false.blank?).to be(true) }
    it("TrueClass returns false") { expect(true.blank?).to be(false) }
    it("Integer returns false") { expect(1.blank?).to be(false) }
    it("Float returns false") { expect(flt.blank?).to be(false) }
    it("Symbol returns false") { expect(:symbol.blank?).to be(false) }
    it("BigDecimal returns false") { expect(big.blank?).to be(false) }
    it("String returns true if empty") { expect("".blank?).to be(true) }
    it("String returns true if unicode whitespace") { expect("\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u202F\u205F\u3000".blank?).to be(true) }
    it("String returns true if regular whitespace") { expect("          ".blank?).to be(true) }
    it("String returns false if not empty") { expect("A string".blank?).to be(false) }
    it("Array returns true if empty") { expect([].blank?).to be(true) }
    it("Array returns false if not empty") { expect(ary.blank?).to be(false) }
    it("Hash returns true if empty") { expect({}.blank?).to be(true) }
    it("Hash returns false if not empty") { expect(hsh.blank?).to be(false) }
    it("Set returns true if empty") { expect(Set.new.blank?).to be(true) }
    it("Set returns false if not empty") { expect(set.blank?).to be(false) }
  end

  context "#present?" do
    it("Object returns true") { expect(Object.new.present?).to be(true) }
    it("NilClass returns false") { expect(nil.present?).to be(false) }
    it("FalseClass returns false") { expect(false.present?).to be(false) }
    it("TrueClass returns true") { expect(true.present?).to be(true) }
    it("Integer returns true") { expect(1.present?).to be(true) }
    it("Float returns true") { expect(flt.present?).to be(true) }
    it("Symbol returns true") { expect(:symbol.present?).to be(true) }
    it("BigDecimal returns true") { expect(big.present?).to be(true) }
    it("String returns false if empty") { expect("".present?).to be(false) }
    it("String returns false if unicode whitespace") { expect("\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A\u202F\u205F\u3000".present?).to be(false) }
    it("String returns false if regular whitespace") { expect("          ".present?).to be(false) }
    it("String returns true if not empty") { expect("A string".present?).to be(true) }
    it("Array returns false if empty") { expect([].present?).to be(false) }
    it("Array returns true if not empty") { expect(ary.present?).to be(true) }
    it("Hash returns false if empty") { expect({}.present?).to be(false) }
    it("Hash returns true if not empty") { expect(hsh.present?).to be(true) }
    it("Set returns false if empty") { expect(Set.new.present?).to be(false) }
    it("Set returns true if not empty") { expect(set.present?).to be(true) }
  end
end
