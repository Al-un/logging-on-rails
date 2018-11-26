module Log
  module Ougai
    # Extend to override datetime format. Can be use to globally change the
    # console output format
    class ConsoleFormatter < ::Ougai::Formatters::Readable
      private
      
      # https://github.com/tilfin/ougai/blob/master/lib/ougai/formatters/base.rb#L42
      # https://apidock.com/ruby/DateTime/strftime
      def default_datetime_format
        '%H:%M:%S.%L'
      end
    end
  end
end
