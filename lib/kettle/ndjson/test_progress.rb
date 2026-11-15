# frozen_string_literal: true

module Kettle
  module Ndjson
    # Aggregates test example outcomes and emits throttled `test_progress` events:
    # a `tick` at most once per interval (default 1s), an immediate `failure` per
    # failed example, and one `final`. Never one event per example.
    #
    # Framework-agnostic: feed it with #record(status, location:, description:)
    # and call #finish at the end. Opt-in via KETTLE_TEST_EVENTS (see .enabled?).
    class TestProgress
      EVENT_TYPE = "test_progress"
      ENV_KEY = "KETTLE_TEST_EVENTS"
      INTERVAL_ENV_KEY = "KETTLE_TEST_EVENTS_INTERVAL"
      DEFAULT_INTERVAL = 1.0

      # @return [Boolean] true when KETTLE_TEST_EVENTS is 1/true/yes/on
      def self.enabled?(env = ENV)
        Env.enabled?(ENV_KEY, env)
      end

      # @return [Float] KETTLE_TEST_EVENTS_INTERVAL seconds, default 1.0 for missing/invalid/negative
      def self.interval_from_env(env = ENV)
        Env.seconds(INTERVAL_ENV_KEY, default: DEFAULT_INTERVAL, env: env)
      end

      # @return [TestProgress, nil] nil unless opted in
      def self.from_env(io:, source:, env: ENV)
        return unless enabled?(env)

        new(io: io, source: source, interval: interval_from_env(env))
      end

      attr_reader :examples, :failures, :pending

      # @param io [#puts] destination (usually $stdout)
      # @param source [String] who is emitting, e.g. "turbo_tests2" or "kettle-test"
      # @param interval [Numeric] minimum seconds between ticks
      # @param clock [#call] monotonic seconds, injectable for tests
      def initialize(io:, source:, interval: DEFAULT_INTERVAL, clock: nil)
        @io = io
        @source = source
        @interval = interval
        @clock = clock || -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) }
        @throttle = Throttle.new(interval: interval, clock: @clock)
        # Leading newline: progress dots share stdout and would otherwise prefix the JSON.
        @events = Kettle::Ndjson.event_stream(io, types: EVENT_TYPE, leading_newline: true)
        @examples = 0
        @failures = 0
        @pending = 0
        @started_at = @clock.call
        @mutex = Mutex.new
      end

      # @param status [Symbol] :passed, :failed or :pending
      def record(status, location: nil, description: nil)
        @mutex.synchronize do
          @examples += 1
          @pending += 1 if status == :pending
          if status == :failed
            @failures += 1
            @throttle.call(force: true) { emit("failure", location: location, description: description) }
          else
            @throttle.call { emit("tick") }
          end
        end
      end

      def finish
        @mutex.synchronize { emit("final") }
      end

      private

      def emit(kind, extra = {})
        Kettle::Ndjson.emit_event(
          @events,
          EVENT_TYPE,
          {
            kind: kind,
            source: @source,
            examples: @examples,
            failures: @failures,
            pending: @pending,
            elapsed: (@clock.call - @started_at).round(2)
          }.merge(extra)
        )
      end
    end
  end
end
