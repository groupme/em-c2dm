# Android Cloud to Device Messaging Framework for Event Machine 

Send push notifications to Android devices.

See [Google's Documention](http://code.google.com/android/c2dm/index.html) to learn more.

## Usage

    require "em-c2dm"

    EM::C2DM.authenticate(username, password)
        
    EM.run do
      EM::C2DM.push(registration_id,
        :alert        => "Hello!",
        :collapse_key => "required"
      )
    end
    
## Custom Params

You can add custom params (which will be converted to `data.<KEY>`):
  
    EM::C2DM.push(registration_id,
      :alert        => "Hello!",
      :collapse_key => "required",
      :custom       => "data",
      :awesome      => true
    )
            
## TODO

* Pass a block to `C2DM.push` to handle response
* Add throttling support
