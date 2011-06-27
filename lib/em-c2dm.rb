require "eventmachine"
require "em-http-request"
require "logger"
require "uuid"
require "uri"
require "em-c2dm/auth"
require "em-c2dm/client"
require "em-c2dm/notification"

$uuid = UUID.new

module EventMachine
  module C2DM
    class << self
      def authenticate(username, password)
        Auth.authenticate(username, password)
      end

      def push(registation_id, options)
        notification = Notification.new(registation_id, options)
        @client ||= Client.new
        @client.deliver(notification)
      end

      def token=(token)
        @token = token
      end

      def token
        return @token if @cache_token && @token
        store.get if store
        @token
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end

      def logger=(new_logger)
        @logger = new_logger
      end
    end
  end
end
