Bundler.require(:default)
require 'json'

RADIODNS_ECC = 'ce1'
CACHE_FILENAME = 'bearer_cache.json'
BEARER_CACHE = {}


def resolve_bearer_id(params)
  if params.is_a?(Hash)
    fqdn = RadioDNS::Resolver.construct_fqdn(
      params.merge(:ecc => RADIODNS_ECC)
    )
  elsif params.is_a?(String) and params.match(/^\w+:\w+/)
    # Convert to DNS entry
    fqdn = params.split(/\W+/).reverse.push('radiodns.org').join('.')
  else
    $stderr.puts "Warning: Unable to parse bearer: #{params}"
    return nil
  end

  if BEARER_CACHE.empty?
    # Read cache from disk
    if File.exist?(CACHE_FILENAME)
      begin
        data = JSON.parse(File.read(CACHE_FILENAME))
        BEARER_CACHE.merge!(data)
      rescue => e
        $stderr.puts "Failed to load bearer cache from disk: #{e}"
      end
    end
  end

  unless BEARER_CACHE.has_key?(fqdn)
    begin
      result = RadioDNS::Resolver.resolve(fqdn)
      if result.nil?
        BEARER_CACHE[fqdn] = nil
      else
        BEARER_CACHE[fqdn] = result.cname
      end

    rescue Resolv::ResolvError
      BEARER_CACHE[fqdn] = nil
    end

    # Write cache to disk
    File.open(CACHE_FILENAME, 'wb') do |file|
      file.write JSON.pretty_generate(BEARER_CACHE)
    end
  end

  return BEARER_CACHE[fqdn]
end
