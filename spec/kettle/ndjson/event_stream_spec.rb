# frozen_string_literal: true

require "stringio"

RSpec.describe Kettle::Ndjson::EventStream do
  let(:io) { StringIO.new }

  it "writes only the JSON line by default" do
    Kettle::Ndjson.event_stream(io, types: "summary").emit(type: "summary", a: 1)
    expect(io.string).to eq(%({"type":"summary","a":1}\n))
  end

  it "prefixes a newline per event with leading_newline: true" do
    stream = Kettle::Ndjson.event_stream(io, types: "summary", leading_newline: true)
    stream.emit(type: "summary", a: 1)
    expect(io.string).to eq(%(\n{"type":"summary","a":1}\n))
  end

  it "writes nothing for filtered-out types, even with leading_newline" do
    Kettle::Ndjson.event_stream(io, types: "summary", leading_newline: true).emit(type: "diagnostic")
    expect(io.string).to eq("")
  end
end
