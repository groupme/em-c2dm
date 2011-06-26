# Android Cloud to Device Messaging Framework for Event Machine 

Send push notifications to Android devices.

## Usage

You need to setup a __token store__ to persist your auth token.

Be sure to set your token if the store does not already have it.

    require "em-c2dm"

    EM::C2DM.store = EM::C2DM::RedisStore.new
    EM::C2DM.token ||= "INITIAL_TOKEN"
        
    EM.run do
      EM::C2DM.push(registration_id, :alert => "Hello!")
    end
    
### Collapse Key

You can also provide a `collapse_key`. See [Google's Documention](http://code.google.com/android/c2dm/index.html) to learn more.

    EM.run do
      EM::C2DM.push(registration_id,
        :alert        => "Hello!",
        :collapse_key => "SOME_COLLAPSE_KEY"
      )
    end

## Token Store

Google loves to constantly invalidate your `auth_token`.

This means you have to store the updated auth token somewhere other than 
in memory.

### RedisStore

To connect to a non-default redis server:

    EM::C2DM.store = EM::C2DM::RedisStore.new("YOUR_REDIS_URL")
    
To supply an existing EM::Redis connection:

    connection = EM::Protocols::Redis.connect(...)
    EM::C2DM.store = EM::C2DM::RedisStore.new(connection)
        
## TODO

* Pass a block to C2DM.push to handle response
