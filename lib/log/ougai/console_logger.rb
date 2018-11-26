module Log
  module Ougai
    # Override default Ougai logger for file logging
    class ConsoleLogger < ::Ougai::Logger
      include ActiveSupport::LoggerThreadSafeLevel
      include LoggerSilence # required

      def initialize(*args)
        super
        after_initialize if respond_to? :after_initialize
      end

      # default JSON format is OK
      def create_formatter
        Log::Ougai::ConsoleFormatter.new
      end
    end
  end
end
