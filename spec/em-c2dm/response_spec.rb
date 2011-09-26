require 'spec_helper'
require "em-c2dm/response"

describe EM::C2DM::Response do
  describe "#duration" do
    it "records difference between start and init" do
      now = Time.now
      Time.stub!(:now).and_return(now)
      response = EM::C2DM::Response.new({}, now - 5)
      response.duration.should == 5.0
    end
  end

  it "can be instantiated from a hash" do
    response = EM::C2DM::Response.new(
      :id           => "abc",
      :status       => 200,
      :retry_after  => 10,
      :client_auth  => "new_token",
      :error        => "InvalidRegistration"
    )

    response.id.should == "abc"
    response.status.should == 200
    response.retry_after.should == 10
    response.client_auth.should == "new_token"
    response.error.should == "InvalidRegistration"
  end

  it "can set individual attributes" do
    response = EM::C2DM::Response.new

    response.id = "abc"
    response.status = 200
    response.retry_after = 10
    response.client_auth = "new_token"
    response.error = "InvalidRegistration"

    response.id.should == "abc"
    response.status.should == 200
    response.retry_after.should == 10
    response.client_auth.should == "new_token"
    response.error.should == "InvalidRegistration"
  end
end
