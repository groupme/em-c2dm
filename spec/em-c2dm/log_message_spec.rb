require 'spec_helper'

describe EM::C2DM::LogMessage do
  before do
    @notification = EM::C2DM::Notification.new("reg_id", :alert => "hi")
  end

  it "logs to info on success" do
    response = EM::C2DM::Response.new(
      :id => "c2dm_id",
      :status => 200
    )

    EM::C2DM.logger.should_receive(:info).with(
      "CODE=200 GUID=#{@notification.uuid} TOKEN=#{@notification.registration_id} TIME=#{response.duration}"
    )

    EM::C2DM::LogMessage.new(@notification, response).log
  end

  it "logs to error on success (with error in payload)" do
    response = EM::C2DM::Response.new(
      :id => "c2dm_id",
      :status => 200,
      :error => "InvalidRegistration"
    )

    EM::C2DM.logger.should_receive(:error).with(
      "CODE=200 GUID=#{@notification.uuid} TOKEN=#{@notification.registration_id} TIME=#{response.duration} ERROR=#{response.error}"
    )

    EM::C2DM::LogMessage.new(@notification, response).log
  end

  it "logs to error on failure" do
    response = EM::C2DM::Response.new(
      :id => "c2dm_id",
      :status => 503,
      :error => "RetryAfter"
    )

    EM::C2DM.logger.should_receive(:error).with(
      "CODE=503 GUID=#{@notification.uuid} TOKEN=#{@notification.registration_id} TIME=#{response.duration} ERROR=#{response.error}"
    )

    EM::C2DM::LogMessage.new(@notification, response).log
  end
end
