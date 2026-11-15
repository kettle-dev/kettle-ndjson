# frozen_string_literal: true

RSpec.describe Kettle::Ndjson::Throttle do
  let(:now) { [0.0] }
  let(:throttle) { described_class.new(interval: 1.0, clock: -> { now[0] }) }
  let(:calls) { [] }

  it "runs the first call, then suppresses calls within the interval" do
    expect(throttle.call { calls << 1 }).to be(true)
    now[0] = 0.9
    expect(throttle.call { calls << 2 }).to be(false)
    expect(calls).to eq([1])
  end

  it "runs again once the interval has elapsed" do
    throttle.call { calls << 1 }
    now[0] = 1.0
    expect(throttle.call { calls << 2 }).to be(true)
    expect(calls).to eq([1, 2])
  end

  it "force bypasses the interval and restarts it" do
    throttle.call { calls << 1 }
    now[0] = 0.2
    expect(throttle.call(force: true) { calls << :forced }).to be(true)
    now[0] = 1.1
    expect(throttle.call { calls << 3 }).to be(false)
    now[0] = 1.2
    expect(throttle.call { calls << 4 }).to be(true)
    expect(calls).to eq([1, :forced, 4])
  end

  it "exposes the interval and defaults to a monotonic clock" do
    t = described_class.new(interval: 2)
    expect(t.interval).to eq(2)
    expect(t.call { calls << :real }).to be(true)
  end
end
