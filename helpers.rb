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