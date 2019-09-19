require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "AuthorizationHeaderParser" do
  context '.parse_params' do
    it 'parses only the parameter string' do
      params = AuthorizationHeaderParser.parse_params('foo=bar, baz=bad')
      expect(params).to eq("foo" => "bar", "baz" => "bad")
    end
  end

  context '.parse' do
    it 'parses a simple Token header with empty parameters' do
      header = 'Token foo=, baz='
      parsed = AuthorizationHeaderParser.parse(header)
      scheme, params = parsed
      expect(scheme).to eq('Token')
      expect(params).to eq("foo" => "", "baz" => "")
    end

    it 'parses a simple Token header with some parameters being empty' do
      header = 'Token foo=, bar="Value", baz='
      parsed = AuthorizationHeaderParser.parse(header)
      scheme, params = parsed
      expect(scheme).to eq('Token')
      expect(params).to eq("foo" => "", "bar" => "Value", "baz" => "")
    end

    it 'parses a simple Token header' do
      header = 'Token foo=bar, baz=bad'
      parsed = AuthorizationHeaderParser.parse(header)
      scheme, params = parsed
      expect(scheme).to eq('Token')
      expect(params).to eq("foo" => "bar", "baz" => "bad")
    end

    it 'parses a header with an escaped quote' do
      digest_header = 'Custom param="value\"such and such\""'
      parsed = AuthorizationHeaderParser.parse(digest_header)
      scheme, params = parsed
      expect(scheme).to eq('Custom')
      expect(params).to eq("param" => 'value"such and such"')
    end

    it "parses a Digest header" do
      digest_header = 'Digest qop="chap",
        realm="testrealm@host.com",
        username="Foobear",
        response="6629fae49393a05397450978507c4ef1",
        cnonce="5ccc069c403ebaf9f0171e9517f40e41"'

      parsed = AuthorizationHeaderParser.parse(digest_header)
      scheme, params = parsed
      expect(scheme).to eq('Digest')
      expect(params).to eq(
        "qop" => "chap",
        "realm" => "testrealm@host.com",
        "username" => "Foobear",
        "response" => "6629fae49393a05397450978507c4ef1",
        "cnonce" => "5ccc069c403ebaf9f0171e9517f40e41"
      )
    end

    it 'parses an OAuth header from Twitter documentation' do
      twitter_header = 'OAuth oauth_consumer_key="xvz1evFS4wEEPTGEFPHBog",
              oauth_nonce="kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg",
              oauth_signature="tnnArxj06cWHq44gCs1OSKk%2FjLY%3D",
              oauth_signature_method="HMAC-SHA1",
              oauth_timestamp="1318622958",
              oauth_token="370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb",
              oauth_version="1.0"'
      parsed = AuthorizationHeaderParser.parse(twitter_header)
      scheme, params = parsed
      expect(scheme).to eq("OAuth")
      expect(params).to eq(
        "oauth_consumer_key" => "xvz1evFS4wEEPTGEFPHBog",
        "oauth_nonce" => "kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg",
        "oauth_signature" => "tnnArxj06cWHq44gCs1OSKk%2FjLY%3D",
        "oauth_signature_method" => "HMAC-SHA1",
        "oauth_timestamp" => "1318622958",
        "oauth_token" => "370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb",
        "oauth_version" => "1.0"
      )
    end

    it 'parses another OAuth params example' do
      oauth_header = 'OAuth realm="",
          oauth_nonce="72250409",
          oauth_timestamp="1294966759",
          oauth_consumer_key="Dummy",
          oauth_signature_method="HMAC-SHA1",
          oauth_version="1.0",
          oauth_signature="IBlWhOm3PuDwaSdxE/Qu4RKPtVE="'

      parsed = AuthorizationHeaderParser.parse(oauth_header)
      scheme, params = parsed
      expect(scheme).to eq("OAuth")
      expect(params).to eq(
        "realm" => "",
        "oauth_nonce" => "72250409",
        "oauth_timestamp" => "1294966759",
        "oauth_consumer_key" => "Dummy",
        "oauth_signature_method" => "HMAC-SHA1",
        "oauth_version" => "1.0",
        "oauth_signature" => "IBlWhOm3PuDwaSdxE/Qu4RKPtVE="
      )
    end
  end

  context 'with invalid headers' do
    it 'raises InvalidHeader' do
      expect {
        AuthorizationHeaderParser.parse_params('foo=bar"')
      }.to raise_error(AuthorizationHeaderParser::InvalidHeader, /Expected end of header or a comma/)

      expect {
        AuthorizationHeaderParser.parse_params('FONDBSJDJAHJDHAHUYHJHJBDA')
      }.to raise_error(AuthorizationHeaderParser::InvalidHeader, /Expected =, but found none/)

      expect {
        AuthorizationHeaderParser.parse_params('foo="bar"baz"bad" another=123')
      }.to raise_error(AuthorizationHeaderParser::InvalidHeader, /Expected end of header or a comma/)
    end
  end
end
