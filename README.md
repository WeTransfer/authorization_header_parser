# authorization_header_parser

Parse custom authorization parameters from `Authorization:` HTTP headers into a neat
Ruby Hash. Works best in combination with `Rack::Auth::AbstractRequest`

For instance, with a custom `Authorization` header of `my-scheme token="12345"`

    auth = Rack::Auth::AbstractRequest.new(env)
    params = AuthorizationHeaderParser.parse_params(auth.params) #=> {'token' => '12345}

or for both scheme and params:

    scheme, params = AuthorizationHeaderParser.parse(env['HTTP_AUTHORIZATION])
    # => ['my-scheme', {'token' => '12345}] 

Works well for token, Digest, OAuth and other schemes using custom authorization parameters.

## Contributing to authorization_header_parser
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2015 Julik Tarkhanov. See LICENSE.txt for
further details.

