# frozen_string_literal: true

RSpec.describe Kettle::Ndjson::Env do
  describe ".truthy?" do
    it "accepts 1/true/yes/on case-insensitively, trimmed" do
      ["1", "true", "YES", " On "].each { |v| expect(described_class.truthy?(v)).to be(true) }
    end

    it "rejects everything else" do
      ["", "0", "false", "no", nil, "maybe"].each { |v| expect(described_class.truthy?(v)).to be(false) }
    end
  end

  describe ".enabled?" do
    it "reads the key from env" do
      expect(described_class.enabled?("X", {"X" => "1"})).to be(true)
      expect(described_class.enabled?("X", {})).to be(false)
    end
  end

  describe ".seconds" do
    it "parses a non-negative float" do
      expect(described_class.seconds("X", default: 1, env: {"X" => "2.5"})).to eq(2.5)
      expect(described_class.seconds("X", default: 1, env: {"X" => "0"})).to eq(0.0)
    end

    it "returns the default when missing, invalid or negative" do
      expect(described_class.seconds("X", default: 1, env: {})).to eq(1.0)
      expect(described_class.seconds("X", default: 1, env: {"X" => "abc"})).to eq(1.0)
      expect(described_class.seconds("X", default: 1, env: {"X" => "-3"})).to eq(1.0)
    end
  end
end
