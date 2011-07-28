require "spec_helper"

describe EventMachine::C2DM do
  describe ".push" do
    before do
      EM::C2DM.deliveries.clear
    end

    it "delivers push notification through a simple interface" do
      expect {
        EM.run_block do
          EM::C2DM.push("ABC", :alert => "hi")
        end
      }.to change { EM::C2DM.deliveries.size }.by(1)

      notification = EM::C2DM.deliveries.first
      notification.params.should == {
        "registration_id" => "ABC",
        "collapse_key" => nil,
        "data.alert" => "hi"
      }
    end
  end
end
