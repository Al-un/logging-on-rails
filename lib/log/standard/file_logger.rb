# frozen_string_literal: true

module Log
  module Standard
    # File logger with json custom format
    class FileLogger < ActiveSupport::Logger
      # Override initialize from
      # https://github.com/rails/rails/blob/master/activesupport/lib/active_support/logger.rb
      def initialize(*args)
        super(*args)
        # Override formatter but leave it opened to overriding
        @formatter = Log::Standard::FileFormatter.new
      end
    end
  end
end
