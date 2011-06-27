require "eventmachine"
require "em-http-request"
require "logger"
require "uuid"
require "uri"
require "em-c2dm/client"
require "em-c2dm/notification"
require "em-c2dm/redis_store"

$uuid = UUID.new

module EventMachine
  module C2DM
    class << self
      def push(registation_id, options)
        notification = EM::C2DM::Notification.new(registation_id, options)
        @client ||= Client.new
        @client.deliver(notification)
      end

      def store
        @store
      end

      def store=(store)
        @store = store
      end

      def token=(token)
        @token = token
      end

      def token
        if @cache_token
          @token ||= store.get
        else
          store.get
        end
      end

      # When running a single process, you can memoize the token without
      # worrying about some other process setting it
      def cache_token=(bool)
        @cache_token = bool
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
