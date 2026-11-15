# frozen_string_literal: true

module Kettle
  module Ndjson
    # Small helpers for env-driven opt-ins.
    module Env
      TRUTHY = %w[1 true yes on].freeze

      module_function

      # @return [Boolean] true for 1/true/yes/on (case-insensitive, trimmed)
      def truthy?(value)
        TRUTHY.include?(value.to_s.strip.downcase)
      end

      # @return [Boolean] whether env[key] is truthy
      def enabled?(key, env = ENV)
        truthy?(env[key])
      end

      # @return [Float] env[key] as non-negative seconds; default when missing, invalid or negative
      def seconds(key, default:, env: ENV)
        raw = env[key]
        return default.to_f if raw.nil?

        value = Float(raw)
        value.negative? ? default.to_f : value
      rescue ArgumentError
        default.to_f
      end
    end
  end
end
