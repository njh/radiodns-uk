require 'erubi'

def link_to_authority(authority)
  if authority && authority.fqdn
    "<a href=\"#{authority.path}\">#{authority.fqdn}</a>"
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
