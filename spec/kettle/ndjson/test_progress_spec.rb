# frozen_string_literal: true

require "stringio"

RSpec.describe Kettle::Ndjson::TestProgress do
  let(:io) { StringIO.new }
  let(:now) { [0.0] }
  let(:progress) { described_class.new(io: io, source: "t", interval: 1.0, clock: -> { now[0] }) }

  def events
    io.string.lines.map(&:strip).reject(&:empty?).map { |line| JSON.parse(line) }
  end

  describe ".enabled? / .from_env / .interval_from_env" do
    it "is off by default" do
      expect(described_class.enabled?({})).to be(false)
      expect(described_class.from_env(io: io, source: "t", env: {})).to be_nil
    end

    it "is on for truthy values" do
      %w[1 true YES on].each { |v| expect(described_class.enabled?({"KETTLE_TEST_EVENTS" => v})).to be(true) }
    end

    it "builds from env with the interval" do
      env = {"KETTLE_TEST_EVENTS" => "1", "KETTLE_TEST_EVENTS_INTERVAL" => "5"}
      expect(described_class.from_env(io: io, source: "t", env: env).instance_variable_get(:@interval)).to eq(5.0)
    end

    it "falls back to the default on garbage or negatives" do
      expect(described_class.interval_from_env({"KETTLE_TEST_EVENTS_INTERVAL" => "abc"})).to eq(1.0)
      expect(described_class.interval_from_env({"KETTLE_TEST_EVENTS_INTERVAL" => "-1"})).to eq(1.0)
      expect(described_class.interval_from_env({})).to eq(1.0)
    end
  end

  it "throttles ticks and never emits per example" do
    5.times { progress.record(:passed) }
    expect(events.size).to eq(1)
    now[0] = 0.5
    progress.record(:passed)
    expect(events.size).to eq(1)
    now[0] = 1.2
    progress.record(:pending)
    expect(events.last).to include(
      "type" => "test_progress", "event_version" => 1, "kind" => "tick", "source" => "t",
      "examples" => 7, "failures" => 0, "pending" => 1, "elapsed" => 1.2
    )
  end

  it "emits an immediate failure event" do
    progress.record(:passed)
    progress.record(:failed, location: "./a_spec.rb:3", description: "A fails")
    expect(events.last).to include("kind" => "failure", "failures" => 1, "examples" => 2, "location" => "./a_spec.rb:3", "description" => "A fails")
  end

  it "emits a final event" do
    progress.record(:passed)
    progress.finish
    expect(events.last).to include("kind" => "final", "examples" => 1)
  end

  it "is a known event type" do
    expect(Kettle::Ndjson.normalize_event_types("test_progress")).to eq(%w[test_progress])
    expect(Kettle::Ndjson::EVENT_TYPES).to include("test_progress")
  end
end
