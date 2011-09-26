require 'spec_helper'
require "em-c2dm/response"

describe EM::C2DM::Response do
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

  describe "#to_s" do
    it "handles success" do
      response = EM::C2DM::Response.new(
        :id           => "abc",
        :status       => 200
      )
      response.to_s.should == "200"
    end

    it "handles InvalidToken" do
      response = EM::C2DM::Response.new(
        :id           => "abc",
        :status       => 401,
        :error        => "InvalidToken"
      )

      response.to_s.should == "401 (InvalidToken)"
    end

    it "handles RetryAfter error" do
      response = EM::C2DM::Response.new(
        :id           => "abc",
        :status       => 502,
        :retry_after  => 123,
        :error        => "RetryAfter"
      )
      response.to_s.should == "502 (RetryAfter)"
    end
  end
end
