# frozen_string_literal: true

module Kettle
  module Ndjson
    # Rate limiter: runs a block at most once per interval, unless forced.
    # A forced call always runs and restarts the interval.
    class Throttle
      attr_reader :interval

      # @param interval [Numeric] minimum seconds between runs
      # @param clock [#call] monotonic seconds, injectable for tests
      def initialize(interval:, clock: nil)
        @interval = interval
        @clock = clock || -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) }
        @last = nil
      end

      # @return [Boolean] true if the block ran
      def call(force: false)
        now = @clock.call
        return false unless force || @last.nil? || now - @last >= @interval

        @last = now
        yield
        true
      end
    end
  end
end
