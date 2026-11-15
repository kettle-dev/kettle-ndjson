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
      TRUTHY = %w[1 true yes on].freeze

      # @return [Boolean] true when KETTLE_TEST_EVENTS is 1/true/yes/on
      def self.enabled?(env = ENV)
        TRUTHY.include?(env[ENV_KEY].to_s.strip.downcase)
      end

      # @return [Float] KETTLE_TEST_EVENTS_INTERVAL seconds, default 1.0 for missing/invalid/negative
      def self.interval_from_env(env = ENV)
        value = Float(env.fetch(INTERVAL_ENV_KEY, DEFAULT_INTERVAL.to_s))
        value.negative? ? DEFAULT_INTERVAL : value
      rescue ArgumentError
        DEFAULT_INTERVAL
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
        @events = Kettle::Ndjson.event_stream(io, types: EVENT_TYPE)
        @examples = 0
        @failures = 0
        @pending = 0
        @started_at = @clock.call
        @last_tick = nil
        @mutex = Mutex.new
      end

      # @param status [Symbol] :passed, :failed or :pending
      def record(status, location: nil, description: nil)
        @mutex.synchronize do
          @examples += 1
          @pending += 1 if status == :pending
          if status == :failed
            @failures += 1
            emit("failure", location: location, description: description)
            @last_tick = @clock.call
          else
            tick_if_due
          end
        end
      end

      def finish
        @mutex.synchronize { emit("final") }
      end

      private

      def tick_if_due
        now = @clock.call
        return if @last_tick && now - @last_tick < @interval

        @last_tick = now
        emit("tick")
      end

      def emit(kind, extra = {})
        # Leading newline: progress dots share stdout and would otherwise prefix the JSON.
        @io.write("\n") if @io.respond_to?(:write)
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
