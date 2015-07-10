require 'strscan'


module AuthorizationHeaderParser
  VERSION = '1.1.0'
  
  class InvalidHeader < StandardError
  end
  
  class ParseError < InvalidHeader
    def initialize(message, scanner)
      str = scanner.string
      from = [(scanner.pos - 5), 0].sort.pop
      upto = [(scanner.pos + 5), str.length].sort.shift
      piece = str[from..upto]
      super "#{message} - at #{scanner.pos} (around #{piece.inspect})"
    end
  end
  
  # Parse a custom scheme + params Authorization header.
  #
  #   parse('absurd-auth token="12345"') #=> ['absurd-auth', {'token' => '12345'}]
  def parse(value)
    scanner = StringScanner.new(value)
    scheme = scanner.scan(NON_WHITESPACE)
    raise InvalidHeader.new("Scheme not provided") unless scheme
    scanner.skip(WHITESPACE)
    
    [scheme.strip, extract_params_from_scanner(scanner)]
  end
  
  # Parse Authorization params. Most useful in combination with Rack::Auth::AbstractRequest
  #
  # For instance, with 'Authorization: absurd-auth token="12345"':
  #
  #   auth = Rack::Auth::AbstractRequest.new(env)
  #   params = parse(auth.params) #=> {'token' => '12345}
  def parse_params(string)
    extract_params_from_scanner(StringScanner.new(string))
  end
  
  extend self
  
  private
  
  ANYTHING_BUT_EQ = /[^\s\=]+/
  EQ = /=/
  UNTIL_BACKSLASH_OR_QUOTE = /[^\\"]+/
  ESCAPED_QUOTE = /\\"/
  QUOTE = /"/
  WHITESPACE = /\s+/
  COMMA = /,/
  NON_WHITESPACE = /[^\s]+/
  
  # http://codereview.stackexchange.com/questions/41270
  # http://stackoverflow.com/questions/134936
  def extract_params_from_scanner(scanner)
    params = {}
    until scanner.eos? do
      key = scanner.scan(ANYTHING_BUT_EQ)
      raise ParseError.new("Expected =, but found none", scanner) unless scanner.skip(EQ)
      
      if scanner.eos? # Last parameter was empty, return
        params[key] = ''
        return params
      end
      
      if scanner.skip(QUOTE) # Quoted value
        buf = ''
        until scanner.eos?
          if scanner.scan(UNTIL_BACKSLASH_OR_QUOTE)
            buf << scanner.matched
          elsif scanner.scan(ESCAPED_QUOTE)
            buf << '"'
          elsif scanner.scan(QUOTE)
            params[key] = buf
            break
          end
        end
      else # Bare parameter
        if bare_value = scanner.scan(/[^,"]+/)
          params[key] = bare_value
        else # Empty parameter
          params[key] = ''
        end
      end
      scanner.skip(WHITESPACE)
      if !scanner.eos? && !scanner.skip(COMMA)
        raise ParseError.new("Expected end of header or a comma", scanner)
      end
      scanner.skip(WHITESPACE)
    end
    params
  end
end
