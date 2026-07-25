# frozen_string_literal: true

RSpec.describe Kettle::Ndjson do
  it "has a version number" do
    expect(described_class::VERSION).not_to be_nil
  end

  it "normalizes default and alias event filters" do
    expect(described_class.normalize_event_types(nil)).to eq(described_class::DEFAULT_EVENT_TYPES)
    expect(described_class.normalize_event_types("progress")).to eq(%w[run_start phase_start phase_finish command_step summary])
    expect(described_class.normalize_event_types("command_step,summary")).to eq(%w[command_step summary])
    expect(described_class.normalize_event_types("command-step,summary")).to eq(%w[command_step summary])
  end

  it "rejects unknown event filters" do
    expect { described_class.normalize_event_types("summary,nope") }
      .to raise_error(Kettle::Ndjson::UnknownEventTypeError, /nope/)
  end

  it "emits compact newline-delimited JSON and flushes the stream" do
    io = StringIO.new
    allow(io).to receive(:flush)
    stream = described_class.event_stream(io, types: "summary")

    stream.emit(type: "diagnostic", message: "hidden")
    stream.emit(type: "summary", status: "ok", ignored: nil)

    expect(io.string.lines.length).to eq(1)
    expect(JSON.parse(io.string)).to eq(
      "type" => "summary",
      "status" => "ok"
    )
    expect(io).to have_received(:flush).once
  end

  it "does nothing when no event target is provided" do
    expect(described_class.emit_event(nil, "summary", status: "ok")).to be_nil
    expect(described_class.record_phase_timing(nil, "release", status: "ok", duration_ms: 1.0)).to be_nil
  end

  it "supports streams that do not expose flush" do
    stream = Class.new do
      attr_reader :lines

      def initialize
        @lines = []
      end

      def puts(line)
        @lines << line
      end
    end.new

    described_class.event_stream(stream, types: "summary").emit(type: "summary", status: "ok")

    expect(JSON.parse(stream.lines.fetch(0))).to include("type" => "summary")
  end

  it "records phase timings independently from event output" do
    stream = described_class.event_stream(StringIO.new, types: "summary")
    recorder = described_class.event_recorder(stream, phase_timings: [])

    described_class.record_phase_timing(
      recorder,
      "release",
      status: "ok",
      duration_ms: 12.3,
      payload: {detail: "done", empty: nil}
    )

    expect(recorder.phase_timings).to eq([
      {detail: "done", phase: "release", status: "ok", duration_ms: 12.3}
    ])
  end

  it "emits phase start and finish events" do
    io = StringIO.new
    stream = described_class.event_stream(io, types: "phase_start,phase_finish")

    described_class.emit_phase_event(stream, :checks, status: "started")
    described_class.emit_phase_event(stream, :checks, status: "ok", duration_ms: 1.2)

    events = io.string.lines.map { |line| JSON.parse(line) }
    expect(events).to contain_exactly(
      include("event_version" => 1, "type" => "phase_start", "phase" => "checks", "status" => "started"),
      include("event_version" => 1, "type" => "phase_finish", "phase" => "checks", "status" => "ok", "duration_ms" => 1.2)
    )
  end

  it "emits command step events with marks" do
    io = StringIO.new
    stream = described_class.event_stream(io, types: "command_step")

    described_class.emit_step_event(
      stream,
      "command_step",
      {name: "bundle_install", status: "started", command: %w[bundle install]},
      phase: "prepare",
      index: 1,
      total: 2
    )
    described_class.emit_step_event(
      stream,
      "command_step",
      {name: "docs", status: "ok", changed_files: ["docs/index.html"]},
      phase: "prepare",
      index: 2,
      total: 2
    )

    events = io.string.lines.map { |line| JSON.parse(line) }
    expect(events.first).to include("mark" => ">", "changed_count" => 0)
    expect(events.last).to include("mark" => "*", "changed_count" => 1, "changed_files" => ["docs/index.html"])
  end

  it "marks failed, blocked, and unchanged command steps distinctly" do
    expect(described_class.step_event_mark({"status" => "failed"})).to eq("F")
    expect(described_class.step_event_mark({"status" => "blocked"})).to eq("F")
    expect(described_class.step_event_mark({"status" => "ok", "changed_files" => []})).to eq(".")
  end

  it "emits diagnostic and summary events" do
    io = StringIO.new
    stream = described_class.event_stream(io, types: "diagnostic,summary")

    described_class.emit_diagnostic_event(stream, {kind: "remote_fetch", message: "cb unavailable", blocking: true})
    described_class.emit_summary_event(stream, status: "failed", diagnostics_count: 1)

    events = io.string.lines.map { |line| JSON.parse(line) }
    expect(events).to contain_exactly(
      include("type" => "diagnostic", "kind" => "remote_fetch", "message" => "cb unavailable", "blocking" => true),
      include("type" => "summary", "status" => "failed", "diagnostics_count" => 1, "mark" => ".")
    )
  end

  it "emits plain string diagnostics and preserves explicit summary marks" do
    io = StringIO.new
    stream = described_class.event_stream(io, types: "diagnostic,summary")

    described_class.emit_diagnostic_event(stream, "plain warning")
    described_class.emit_summary_event(stream, status: "blocked", mark: "F")

    events = io.string.lines.map { |line| JSON.parse(line) }
    expect(events.first).to include("type" => "diagnostic", "message" => "plain warning")
    expect(events.last).to include("type" => "summary", "status" => "blocked", "mark" => "F")
  end

  it "records events through a recorder only when a stream is present" do
    io = StringIO.new
    recorder = described_class.event_recorder(described_class.event_stream(io, types: "summary"))
    silent = described_class.event_recorder

    recorder.emit(type: "summary", status: "ok")
    silent.emit(type: "summary", status: "hidden")

    expect(JSON.parse(io.string)).to include("type" => "summary", "status" => "ok")
    expect(silent.phase_timings).to be_empty
  end
end
