require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'
# require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LoggingOnRails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # https://blog.bigbinary.com/2016/08/29/rails-5-disables-autoloading-after-booting-the-app-in-production.html
    config.eager_load_paths << Rails.root.join('lib')

    # ---------- Here comes the fun !! -----------------------------------------
    # Loading environment variable before Application configuration
    Dotenv::Railtie.load

    # I require files only when the logging configuration requires which I 
    # guess is quite a bad practice to have require within the Application class.
    # Whenever possible and for consistency reasons, use +require+ along with
    # other requires above module definition
    logger_config = ENV['LOGGER_CONFIG']
    case logger_config
    # [Standard Logger] --------------------------------------------------------
    when 'STANDARD_V1'
      config.logger = ActiveSupport::Logger.new(STDOUT)

    when 'STANDARD_V2'
      config.log_level = :info
      logger = ActiveSupport::Logger.new(STDOUT)
      config.logger = ActiveSupport::TaggedLogging.new(logger)

    when 'STANDARD_V3'
      require 'log/standard/console_logger'
      require 'log/standard/console_formatter'
      logger = Log::Standard::ConsoleLogger.new(STDOUT)
      config.logger = ActiveSupport::TaggedLogging.new(logger)

    when 'STANDARD_V4'
      require 'log/standard/console_logger'
      require 'log/standard/console_formatter'
      require 'log/standard/file_logger'
      require 'log/standard/file_formatter'
      # don't forget the tagged logging wrap
      logger_file     = ActiveSupport::TaggedLogging.new(Log::Standard::FileLogger.new(Rails.root.join('log/custom.log')))
      logger_console  = ActiveSupport::TaggedLogging.new(Log::Standard::ConsoleLogger.new(STDOUT))
      # Attempt to separate log level but completely ignored
      logger_file.level     = :debug
      logger_console.level  = :info
      # if I use logger_file as primary logger, everything is ignored
      logger_console.extend(ActiveSupport::Logger.broadcast(logger_file))
      config.logger = logger_console

    # [Logging] ----------------------------------------------------------------
    when 'LOGGING_V1'
      require 'logging'
      logger = Logging.logger(STDOUT)
      logger.level = :warn
      config.logger = logger

    when 'LOGGING_V2'
      require 'logging'
      require 'logging/rails'
      # For simplicity purpose, I added these entries in application.rb but 
      # logging generators added these in development.rb, test.rb and production.rb
      # If using logging library, please do following logging practices
      # Set the logging destination(s)
      config.log_to = %w[stdout file]
      # Show the logging configuration on STDOUT
      config.show_log_configuration = true

    # [Lograge] ----------------------------------------------------------------
    when 'LOGRAGE'
      # do nothing special: use default Ruby logger
      config.logger = ActiveSupport::Logger.new(STDOUT)

    # [Ougai] ------------------------------------------------------------------
    when 'OUGAI_V1'
      require 'log/ougai/console_formatter'
      require 'log/ougai/console_logger'
      require 'log/ougai/file_logger'
      file_logger = Log::Ougai::FileLogger.new(Rails.root.join('log/ougai_dev.log'))
      console_logger  = Log::Ougai::ConsoleLogger.new(STDOUT)
      # broadcasting: https://github.com/tilfin/ougai#using-broadcast-log-output-plural-targets
      console_logger.extend(Ougai::Logger.broadcast(file_logger))
      config.logger = console_logger

    # [Loggly] -----------------------------------------------------------------
    when 'LOGGLY'
      # nothing special
      config.logger = ActiveSupport::Logger.new(STDOUT)

    # [Final] ------------------------------------------------------------------
    when 'FINAL'
      require 'log/ougai/logger'
      color_config = Ougai::Formatters::Colors::Configuration.new(
        severity: {
          trace:  Ougai::Formatters::Colors::WHITE,
          debug:  Ougai::Formatters::Colors::GREEN,
          info:   Ougai::Formatters::Colors::CYAN,
          warn:   Ougai::Formatters::Colors::YELLOW,
          error:  Ougai::Formatters::Colors::RED,
          fatal:  Ougai::Formatters::Colors::PURPLE
        },
        msg: :severity,
        datetime: {
          default:  Ougai::Formatters::Colors::PURPLE,
          error:  Ougai::Formatters::Colors::RED,
          fatal:  Ougai::Formatters::Colors::RED
        }
      )

      EXCLUDED_FIELD = [].freeze
      LOGRAGE_REJECT = [:sql_queries, :sql_queries_count].freeze

      console_message = proc do |severity, datetime, _progname, data|
        # Remove :msg regardless the outcome
        msg = data.delete(:msg)
        # Lograge specfic stuff: main controller output handled by
        # msg formatter
        if data.key?(:request)
          lograge = data[:request]
                    .reject { |k, _v| LOGRAGE_REJECT.include?(k) }
                    .map { |key, val| "#{key}: #{val}" }
                    .join(', ')
          msg = color_config.color(:msg, lograge, severity)
        # Standard text
        else
          msg = color_config.color(:msg, msg, severity)
        end

        # Standardize output
        format('%-5s %s: %s',
               color_config.color(:severity, severity, severity),
               color_config.color(:datetime, datetime, severity),
               msg)
      end

      console_data = proc do |data|
        # Lograge specfic stuff: main controller output handled by msg formatter
        if data.key?(:request)
          lograge_data = data[:request]
          if lograge_data.key?(:sql_queries)
            lograge_data[:sql_queries].map do |sql_query|
              format('%<duration>6.2fms %<name>25s %<sql>s (%<type_casted_binds>s)',
                    sql_query)
            end
            .join("\n")
          else
            nil
          end
        # Default styling
        else
          EXCLUDED_FIELD.each { |field| data.delete(field) }
          next nil if data.empty?

          data.ai
        end
      end

      console_formatter = Ougai::Formatters::Customizable.new(
        # Console output
        format_msg: console_message,
        format_data: console_data
      )
      console_formatter.datetime_format = '%H:%M:%S.%L'
      file_formatter            = Ougai::Formatters::Bunyan.new
      file_logger               = Log::Ougai::Logger.new(Rails.root.join('log/final_dev.log'))
      file_logger.formatter     = file_formatter
      console_logger            = Log::Ougai::Logger.new(STDOUT)
      console_logger.formatter  = console_formatter
      console_logger.extend(Ougai::Logger.broadcast(file_logger))
      config.logger = console_logger
    end
  end
end
