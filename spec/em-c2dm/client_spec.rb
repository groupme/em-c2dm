require 'spec_helper'

describe EM::C2DM::Client do
  before do
    EM::C2DM.token = "token"
  end

  describe "200" do
    before do
      stub_request(:post, EM::C2DM::Client::URL).with(
        :query => {
          "collapse_key"    => nil,
          "data.alert"      => "hi",
          "registration_id" => "ABC"
        },
        :headers => {
          'Authorization'=>'GoogleLogin auth=token',
          'Content-Length'=>'0',
          'User-Agent'=>'em-c2dm 0.0.1'
        }
      ).to_return(
        :status => 200,
        :body => "id=123abc\nError=InvalidRegistration"
      )

      EM.run_block do
        EM::C2DM.push("ABC", :alert => "hi") do |response|
          @response = response
        end
      end
    end

    it "sets status" do
      @response.status.should == 200
    end

    it "parses id from body" do
      @response.id.should == "123abc"
    end

    it "parses error from body when present" do
      @response.error.should == "InvalidRegistration"
    end
  end

  describe "Update-Client-Auth" do
    before do
      stub_request(:post, EM::C2DM::Client::URL).with(
        :query => {
          "collapse_key"    => nil,
          "data.alert"      => "hi",
          "registration_id" => "ABC"
        },
        :headers => {
          'Authorization'=>'GoogleLogin auth=token',
          'Content-Length'=>'0',
          'User-Agent'=>'em-c2dm 0.0.1'
        }
      ).to_return(
        :status => 200,
        :headers => {
          "Update-Client-Auth" => "new_token"
        }
      )
    end

    it "sets token from header" do
      EM.run_block do
        EM::C2DM.push("ABC", :alert => "hi") do |response|
          response.client_auth.should == "new_token"
        end
      end
      EM::C2DM.token.should == "new_token"
    end
  end

  describe "401" do
    before do
      stub_request(:post, EM::C2DM::Client::URL).with(
        :query => {
          "collapse_key"    => nil,
          "data.alert"      => "hi",
          "registration_id" => "ABC"
        },
        :headers => {
          'Authorization'=>'GoogleLogin auth=token',
          'Content-Length'=>'0',
          'User-Agent'=>'em-c2dm 0.0.1'
        }
      ).to_return(
        :status => 401
      )

      EM.run_block do
        EM::C2DM.push("ABC", :alert => "hi") do |response|
          @response = response
        end
      end
    end

    it "sets status" do
      @response.status.should == 401
    end

    it "sets InvalidToken error" do
      @response.error.should == "InvalidToken"
    end
  end


  describe "503 (Retry-After)" do
    before do
      stub_request(:post, EM::C2DM::Client::URL).with(
        :query => {
          "collapse_key"    => nil,
          "data.alert"      => "hi",
          "registration_id" => "ABC"
        },
        :headers => {
          'Authorization'=>'GoogleLogin auth=token',
          'Content-Length'=>'0',
          'User-Agent'=>'em-c2dm 0.0.1'
        }
      ).to_return(
        :status => 503,
        :headers => { "Retry-After" => "1234"}
      )

      EM.run_block do
        EM::C2DM.push("ABC", :alert => "hi") do |response|
          @response = response
        end
      end
    end

    it "sets status" do
      @response.status.should == 503
    end

    it "sets RetryAfter error" do
      @response.error.should == "RetryAfter"
    end

    it "sets retry_after duration" do
      @response.retry_after.should == 1234
    end
  end

  describe "a network error" do
    before do
      stub_request(:post, EM::C2DM::Client::URL).with(
        :query => {
          "collapse_key"    => nil,
          "data.alert"      => "Error",
          "registration_id" => "ABC"
        },
        :headers => {
          'Authorization'=>'GoogleLogin auth=token',
          'Content-Length'=>'0',
          'User-Agent'=>'em-c2dm 0.0.1'
        }
      ).to_timeout

      @log = StringIO.new
      EM::C2DM.logger = Logger.new(@log)
    end

    it "logs the error" do
      EM.run_block { EM::C2DM.push("ABC", :alert => "Error") }
      @log.rewind
      @log.read.should include("ERROR")
    end

    it "does not run the passed block" do
      block_called = false

      EM.run_block do
        EM::C2DM.push("ABC", :alert => "Error") do
          block_called = true
        end
      end

      block_called.should be_false
    end
  end
end
