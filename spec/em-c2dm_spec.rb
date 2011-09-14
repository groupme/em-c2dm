require "spec_helper"

describe EventMachine::C2DM do
  describe ".push" do
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
        :body => "id=123abc"
      )
    end

    it "delivers push notification through a simple interface" do
      EM::C2DM.token = "token"
      EM.run_block do
        EM::C2DM.push("ABC", :alert => "hi") do |response|
          response.should be_success
        end
      end
    end
  end
end
