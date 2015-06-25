$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'authorization_header_parser'

RSpec.configure do |config|
  config.order = 'random'
end
