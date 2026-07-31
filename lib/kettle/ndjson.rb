# frozen_string_literal: true

require "json"
require "version_gem"

require_relative "ndjson/version"

module Kettle
  module Ndjson
    EVENT_TYPES = %w[
      run_start
      phase_start
      phase_finish
      command_step
      secret_provider
      diagnostic
      summary
    ].freeze
    DEFAULT_EVENT_TYPES = EVENT_TYPES.freeze
    EVENT_TYPE_ALIASES = {
      "all" => EVENT_TYPES,
      "default" => DEFAULT_EVENT_TYPES,
      "progress" => %w[run_start phase_start phase_finish command_step summary]
    }.freeze

    class Error < StandardError; end
    class UnknownEventTypeError < Error; end

    module_function

    def event_stream(io, types: nil, event_types: EVENT_TYPES, aliases: EVENT_TYPE_ALIASES)
      EventStream.new(io, types: normalize_event_types(types, event_types: event_types, aliases: aliases))
    end

    def event_recorder(stream = nil, phase_timings: [])
      EventRecorder.new(stream, phase_timings)
    end

    def normalize_event_types(types, event_types: EVENT_TYPES, aliases: EVENT_TYPE_ALIASES)
      requested = types.to_s.strip
      tokens = requested.empty? ? ["default"] : requested.split(",").map { |token| token.strip }.reject(&:empty?)
      normalized = tokens.flat_map do |token|
        normalized_token = token.tr("-", "_")
        aliases.fetch(normalized_token) { normalized_token }
      end.map(&:to_s).uniq
      unknown = normalized - event_types.map(&:to_s)
      raise UnknownEventTypeError, "Unknown event type(s): #{unknown.join(", ")}" unless unknown.empty?

      normalized
    end

    def emit_event(events, type, payload = {})
      return unless events

      events.emit(payload.merge(type: type, event_version: 1))
    end

    def emit_phase_event(events, phase, status:, **payload)
      event_type = (status.to_s == "started") ? "phase_start" : "phase_finish"
      emit_event(events, event_type, payload.merge(phase: phase.to_s, status: status))
    end

    def record_phase_timing(events, phase, status:, duration_ms:, payload: {})
      return unless events.respond_to?(:record_phase_timing)

      events.record_phase_timing(
        compact_payload(
          payload.merge(
            phase: phase.to_s,
            status: status,
            duration_ms: duration_ms
          )
        )
      )
    end

    def emit_step_event(events, event_type, step, phase:, index: nil, total: nil)
      emit_event(
        events,
        event_type,
        phase: phase.to_s,
        index: index,
        total: total,
        name: payload_value(step, :name),
        status: payload_value(step, :status),
        reason: payload_value(step, :reason),
        command: payload_value(step, :command),
        path: payload_value(step, :path),
        changed_files: Array(payload_value(step, :changed_files) || []),
        changed_count: Array(payload_value(step, :changed_files) || []).length,
        mark: step_event_mark(step)
      )
    end

    def emit_diagnostic_event(events, diagnostic, index: nil, total: nil)
      payload = diagnostic.respond_to?(:to_h) ? diagnostic.to_h : {message: diagnostic.to_s}
      emit_event(
        events,
        "diagnostic",
        index: index,
        total: total,
        kind: payload[:kind] || payload["kind"] || payload[:key] || payload["key"],
        severity: payload[:severity] || payload["severity"],
        path: payload[:path] || payload["path"],
        message: payload[:message] || payload["message"] || diagnostic.to_s,
        blocking: payload[:blocking] || payload["blocking"]
      )
    end

    def emit_summary_event(events, payload)
      emit_event(events, "summary", payload.merge(mark: payload.fetch(:mark, ".")))
    end

    def step_event_mark(step)
      return ">" if payload_value(step, :status).to_s == "started"
      return "F" if %w[failed blocked].include?(payload_value(step, :status).to_s)

      Array(payload_value(step, :changed_files) || []).empty? ? "." : "*"
    end

    def payload_value(payload, key)
      return payload.public_send(key) if payload.respond_to?(key)

      payload.fetch(key, payload.fetch(key.to_s, nil))
    end

    def compact_payload(payload)
      payload.to_h.compact
    end

    class EventStream
      def initialize(io, types:)
        @io = io
        @types = types.map(&:to_s)
      end

      attr_reader :types

      def emit(payload)
        return unless @types.include?(payload.fetch(:type).to_s)

        @io.puts(JSON.generate(Kettle::Ndjson.compact_payload(payload)))
        @io.flush if @io.respond_to?(:flush)
      end
    end

    class EventRecorder
      def initialize(stream = nil, phase_timings = [])
        @stream = stream
        @phase_timings = phase_timings
      end

      attr_reader :phase_timings

      def emit(payload)
        @stream&.emit(payload)
      end

      def record_phase_timing(payload)
        @phase_timings << Kettle::Ndjson.compact_payload(payload)
      end
    end
  end
end

Kettle::Ndjson::Version.class_eval do
  extend VersionGem::Basic
end
