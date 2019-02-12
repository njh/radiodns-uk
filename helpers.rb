require 'erubi'

def content_tag(element, body=nil, options={})
  attr = options.map {|key, value| "#{Erubi.h key}=\"#{Erubi.h value}\""}.join(' ')
  attr = ' ' + attr unless attr.empty?
  unless body.nil?
    "<#{Erubi.h element}#{attr}>#{Erubi.h body}</#{Erubi.h element}>"
  else
    "<#{Erubi.h element}#{attr} />"
  end
end

def link_to(text, href=nil, options={})
  options[:href] ||= (href || text)
  content_tag('a', text, options)
end

def nav_item(text, href)
  klass = 'nav-item'
  klass += ' active' if request.path.start_with?(href)
  "<li class='#{klass}'>" +
  link_to(text, href, :class => 'nav-link') +
  "</li>"
end

def link_to_authority(authority)
  if authority && authority.fqdn
    link_to(authority.fqdn, authority.path)
  else
    tick_cross(false) + ' No RadioDNS'
  end
end

def tick_cross(bool)
  if bool
    '<span style="margin-right: 0.5em; color: green; font-weight: bolder">✓</span>'
  else
    '<span style="margin-right: 0.5em; color: red; font-weight: bolder">✗</span>'
  end
end

def canonical_url
  "https://www.radiodns.uk" + request.path
end

def pretty_filesize(path)
  fullpath = File.join('public', path)
  bytes = File.size(fullpath)
  "#{bytes / 1024}k"
end

def format_csv(csv, objects, *keys)
  # Header Row
  csv << keys.map {|key| key.to_s.gsub(/_/,' ').titleize}

  # Data Row
  objects.each do |obj|
    csv << keys.map {|key| obj.send(key)}
  end
end

def format_power(kilowatts)
  if kilowatts >= 1.0
    format("%2.2f kW", kilowatts)
  else
    format("%d Watts", kilowatts * 1000)
  end
end
