require 'strscan'


module AuthorizationHeaderParser
  VERSION = '1.0.0'
  InvalidHeader = Class.new(StandardError)
  
  # Parse a custom scheme + params Authorization header.
  #
  #   parse('absurd-auth token="12345"') #=> ['absurd-auth', {'token' => '12345}]
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
  UNTIL_FWD_SLASH_OR_QUOTE = /[^\\"]+/
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
      raise InvalidHeader, "Expected =, but found none at #{scanner.pos}" unless scanner.scan(EQ)
      value_opener = scanner.get_byte
      raise InvalidHeader, "Expected opening of a parameter at #{scanner.pos}" unless value_opener
      if value_opener == '"' # Quoted value
        buf = ''
        until scanner.eos?
          if scanner.scan(UNTIL_FWD_SLASH_OR_QUOTE)
            buf << scanner.matched
          elsif scanner.scan(ESCAPED_QUOTE)
            buf << '"'
          elsif scanner.scan(QUOTE)
            params[key] = buf
            break
          end
        end
      else
        scanner.unscan # Bare parameter, backtrack 1 byte
        unless bare_value = scanner.scan(/[^,"]+/)
          raise InvalidHeader, "Expected a bare parameter value at #{scanner.pos}"
        end
        params[key] = bare_value
      end
      scanner.skip(WHITESPACE)
      if !scanner.eos? && !scanner.skip(COMMA)
        raise InvalidHeader, "Expected end of header or a comma, at #{scanner.pos}"
      end
      scanner.skip(WHITESPACE)
    end
    params
  end
end
