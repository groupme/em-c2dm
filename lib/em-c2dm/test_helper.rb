# Test helper for EM::C2DM
#
# To use this, start by simply requiring this file after EM::C2DM has already
# been loaded
#
#     require "em-c2dm"
#     require "em-c2dm/test_helper"
#
# This will nullify actual deliveries and instead, push them onto an accessible
# list:
#
#     expect {
#       EM::C2DM.push(token, aps, custom)
#     }.to change { EM::C2DM.deliveries.size }.by(1)
#
#     notification = EM::C2DM.deliveries.first
#     notification.should be_an_instance_of(EM::C2DM::Notification)
#     notification.payload.should == ...
#
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
