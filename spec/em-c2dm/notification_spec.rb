require 'spec_helper'

describe EM::C2DM::Notification do
  describe "#params" do
    it "includes does not allow empty options" do
      lambda {
        EM::C2DM::Notification.new("ABC")
      }.should raise_error

      lambda {
        EM::C2DM::Notification.new("ABC", {})
      }.should raise_error
    end

    it "includes registration_id and collapse_key" do
      notification = EM::C2DM::Notification.new("ABC",
        :collapse_key => "foo",
        :alert        => "bar"
      )
      notification.params.should == {
        "registration_id" => "ABC",
        "collapse_key"    => "foo",
        "data.alert"      => "bar"
      }
    end

    it "accepts string parameters" do
      notification = EM::C2DM::Notification.new("ABC",
        "collapse_key" => "foo",
        "alert"        => "bar"
      )
      notification.params.should == {
        "registration_id" => "ABC",
        "collapse_key"    => "foo",
        "data.alert"      => "bar"
      }
    end

    it "prefixes all other params with 'data.'" do
      notification = EM::C2DM::Notification.new("ABC",
        :collapse_key => "foo",
        :alert        => "bar",
        :biz          => "baz",
        :fizz         => "buzz"
      )
      notification.params.should == {
        "registration_id" => "ABC",
        "collapse_key"    => "foo",
        "data.alert"      => "bar",
        "data.biz"        => "baz",
        "data.fizz"       => "buzz"
      }
    end
  end
end
