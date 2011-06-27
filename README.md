# Android Cloud to Device Messaging Framework for Event Machine 

Send push notifications to Android devices.

See [Google's Documention](http://code.google.com/android/c2dm/index.html) to learn more.

## Usage

    require "em-c2dm"

    EM::C2DM.authenticate(username, password)
        
    EM.run do
      EM::C2DM.push(registration_id, :alert => "Hello!")
    end
    
## Custom Params

You can add custom params (which will be converted to `data.<KEY>`):
  
    EM::C2DM.push(registration_id,
      :alert    => "Hello!",
      :custom   => "data",
      :awesome  => true
    )
    
    
## Collapse Key

You can also provide a `collapse_key`:

    EM::C2DM.push(registration_id,
      :alert        => "Hello!",
      :collapse_key => "SOME_COLLAPSE_KEY"
    )
        
## TODO

* Pass a block to `C2DM.push` to handle response
