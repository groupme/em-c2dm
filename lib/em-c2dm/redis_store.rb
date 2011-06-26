module EventMachine
  module C2DM
    class RedisStore
      KEY = "em-c2dm:auth_token"

      def initialize(redis)
        @redis = redis.is_a?(String) ? connect(redis) : redis
      end

      def set(token)
        @redis.set(KEY, token)
      end

      def get
        @redis.get(KEY)
      end

      def redis
        @redis
      end

      private

      def connect(url = nil)
        url = URI(url || "redis://127.0.0.1:6379/0")
        args[:host]     ||= url.host
        args[:port]     ||= url.port
        args[:password] ||= url.password
        args[:db]       ||= url.path[1..-1].to_i

        EM::Protocols::Redis.connect(args)
      end
    end
  end
end
