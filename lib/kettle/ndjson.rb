# frozen_string_literal: true

require "version_gem"

require_relative "ndjson/version"

module Kettle
  module Ndjson
    class Error < StandardError; end
    # Your code goes here...
  end
end

Kettle::Ndjson::Version.class_eval do
  extend VersionGem::Basic
end
