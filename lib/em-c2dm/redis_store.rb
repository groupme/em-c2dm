module EventMachine
  module C2DM
    class RedisStore
      KEY = "em-c2dm:token"

      def initialize(redis)
        @redis = if redis.is_a?(String) || redis.nil?
          connect(redis)
        else
          redis
        end
      end

      def set(token, stop = false)
        @redis.set(KEY, token) do |token|
          EM::C2DM.token = token
          EM::C2DM.logger.info("set token to #{token}: #{response}")
          EM.stop if stop
        end
      end

      def get(stop = false)
        @redis.get(KEY) do |response|
          EM::C2DM.token = response
          EM.stop if stop
        end
        true
      end

      def redis
        @redis
      end

      private

      def connect(url = nil)
        url = URI(url || "redis://127.0.0.1:6379/0")
        EM::Protocols::Redis.connect(
          :host     => url.host,
          :port     => url.port,
          :password => url.password,
          :db       => url.path[1..-1].to_i
        )
      end
    end
  end
end
