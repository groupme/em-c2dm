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

    class_eval do
      def push(registation_id, options, &block)
        notification = Notification.new(registation_id, options)
        EM::C2DM.deliveries << notification
        fake_response = EM::C2DM::Response.new(
          :status => 200,
          :id     => "123"
        )
        block.call(fake_response) if block_given?
      end
    end
  end
end
