Bundler.require(:default)

RADIODNS_ECC = 'ce1'



def resolve_bearer_id(params)

  begin
  
    if params.is_a?(Hash)
      fqdn = RadioDNS::Resolver.construct_fqdn(
        params.merge(:ecc => RADIODNS_ECC)
      )
    elsif params.is_a?(String) and params.match(/^\w+:\w+/)
      # Convert to DNS entry
      fqdn = params.split(/\W+/).reverse.push(RadioDNS::Resolver.root_domain).join('.')
    else
      $stderr.puts "Warning: Unable to parse bearer: #{params}"
      return nil
    end

    result = RadioDNS::Resolver.resolve(fqdn)
    unless result.nil?
      return result.cname
    end

  rescue Resolv::ResolvError
    return nil
  end

end
