module EventMachine
  module C2DM
    def self.deliveries
      @deliveries ||= []
    end

    Auth.class_eval do
      def self.authenticate(username, password)
        EM::C2DM.token = "TEST_TOKEN"
      end
    end

    Client.class_eval do
      def deliver(block)
        EM::C2DM.deliveries << @notification
      end
    end
  end
end
