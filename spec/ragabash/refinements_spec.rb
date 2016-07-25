# frozen_string_literal: true
require "spec_helper"

describe Ragabash::Refinements do
  using ::Ragabash::Refinements

  context "#deep_freeze" do
    it "freezes nested objects" do
      hash = { first: { second: String.new("Unfrozen string") } }
      expect(hash.deep_freeze[:first][:second]).to be_frozen
    end
  end

  context "#deep_freeze!" do
    it "freezes nested objects, skipping already-frozen ones" do
      hash = { first: { second: String.new("Unfrozen string") }.freeze }
      expect(hash.deep_freeze![:first][:second]).not_to be_frozen
    end
  end

  context "#try_dup" do
    it("NilClass returns self") { expect(nil.try_dup).to equal(nil) }
    it("FalseClass returns self") { expect(false.try_dup).to equal(false) }
    it("TrueClass returns self") { expect(true.try_dup).to equal(true) }
    it("Fixnum returns self") { expect(1.try_dup).to equal(1) }
    it("Float returns self") { expect(1.15.try_dup).to equal(1.15) }
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
    it("Fixnum returns self") { expect(1.deep_dup).to equal(1) }
    it("Float returns self") { expect(1.15.deep_dup).to equal(1.15) }
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

  context "#safe_copy" do
    it("NilClass returns self") { expect(nil.safe_copy).to equal(nil) }
    it("FalseClass returns self") { expect(false.safe_copy).to equal(false) }
    it("TrueClass returns self") { expect(true.safe_copy).to equal(true) }
    it("Fixnum returns self") { expect(1.safe_copy).to equal(1) }
    it("Float returns self") { expect(1.15.safe_copy).to equal(1.15) }
    it("Symbol returns self") { expect(:symbol.safe_copy).to equal(:symbol) }
    it("BigDecimal duplicates and freeze") do
      expect(BigDecimal.new("1.5").safe_copy).to not_equal(BigDecimal.new("1.5"))
        .and eq(BigDecimal.new("1.5")).and be_frozen
    end
    it("Frozen string returns self") do
      expect("A string".safe_copy).to equal("A string").and be_frozen
    end
    it("String duplicates and freeze") do
      expect(String.new("A string").safe_copy).to not_equal("A string")
        .and eq("A string").and be_frozen
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
end
