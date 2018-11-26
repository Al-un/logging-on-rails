# frozen_string_literal: true

Rails.application.configure do
  logger_config       = ENV['LOGGER_CONFIG']
  lograge_enabled     = logger_config == 'FINAL' || logger_config.start_with?('LOGRAGE')
  lograge_sql_enabled = ['LOGRAGE_V2', 'FINAL'].include?(logger_config)

  if lograge_enabled
    config.lograge.enabled = true
    config.lograge.formatter = Class.new do |fmt|
      def fmt.call(data)
        { request: data }
      end
    end
    # For API only
    # config.lograge.base_controller_class = 'ActionController::API'

    # add additional fields to lograge, enriched in 
    # app/controllers/application_controller.rb
    config.lograge.custom_options = lambda do |event|
      # https://www.reddit.com/r/rails/comments/5u1lzn/rails_production_logging_in_2017/ddrrqei
      { remote_ip: event.payload[:remote_ip] }
    end
  end

  # Lograge SQL
  if lograge_sql_enabled
    require 'lograge/sql/extension'
    event_extractor = proc do |event|
      # puts '~~~~~~~~'
      # puts event.inspect
      # puts '~~~~~~~~'
      {
        name: event.payload[:name],
        duration: event.duration.to_f.round(2),
        sql: event.payload[:sql],
        type_casted_binds: event.payload[:type_casted_binds].inspect
      }
    end

    config.lograge_sql.extract_event = event_extractor
    config.lograge_sql.formatter = proc do |sql_queries|
      sql_queries
    end
  end
end
