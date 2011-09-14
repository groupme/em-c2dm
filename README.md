# Android Cloud to Device Messaging Framework for Event Machine 

Send push notifications to Android devices.

See [Google's Documention](http://code.google.com/android/c2dm/index.html) to learn more.

## Usage

    require "em-c2dm"

    EM::C2DM.authenticate(username, password)
        
    EM.run do
      EM::C2DM.push("registration_id", :alert => "hi!", :collapse_key => "required")
    end
    
### Custom Params

You can add custom params (which will be converted to `data.<KEY>`):
  
    EM::C2DM.push(registration_id,
      :alert        => "Hello!",
      :collapse_key => "required",
      :custom       => "data",
      :awesome      => true
    )
            

### Response Callback

You can register a response callback to check success and handle errors:

    EM::C2DM.push("registration_id", :alert => "hi!") do |response|
      if response.success?
        puts "success! id=#{response.id}" # ID of sent message
      else
        case response.error
        when "InvalidToken"
          # reauthenticate
        when "InvalidRegistration"
          # clear our registration id
        when "RetryAfter"
          # pause sending for response.retry_after seconds
        end        
      end
    end

## Testing

### Deliveries

If you include `em-c2dm/test_helper` no deliveries will be made.

Instead, `EM::C2DM.deliveries` will be populated with 
`EM::C2DM::Notification` object.

    require "em-c2dm"
    require "em-c2dm/test_helper"
    
    expect {
      EM::C2DM.push("reg_id", :alert => "hi!", :collapse_key => "foo")
    }.to change { EM::C2DM.deliveries.size }.by(1)

    notification = EM::C2DM.deliveries.first
    notification.should be_an_instance_of(EM::C2DM::Notification)
    notification.params.should == {
      "registration_id" => "reg_id",
      "collapse_key"    => "foo",
      "data.alert"      => "hi!"
    }

### Stubbing Responses

You can also provide stubbed responses to yield to your callbacks.

    response = EM::C2DM::Response.new(
      :status => 200,
      :id     => "abc",
      :error  => "QuotaExceeded"
    )
    
    EM::C2DM.stub!(:push).and_yield(response)

## Contributing

Please feel free to fork and update this!