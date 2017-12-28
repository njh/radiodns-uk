#!/usr/bin/env ruby

require 'bundler/setup'
require 'find'
Bundler.require(:default)


MIME_TYPE_MAP = {
  :css => 'text/css',
  :csv => 'text/csv',
  :html => 'text/html',
  :ico => 'image/x-icon',
  :js => 'text/javascript',
  :json => 'application/json',
  :map => 'application/json',
  :png => 'image/png',
  :svg => 'image/svg+xml',
  :ttl => 'text/turtle',
  :txt => 'text/plain',
  :xml => 'application/xml',
  :xslt => 'application/xml',
}

CACHE_CONTROL = 'public,max-age=3600'




# First create a list of files
filelist = {}
Find.find('build/') do |localpath|
  next unless FileTest.file?(localpath)
  next if File.basename(localpath).match(/^\./)
  
  remotepath = localpath.sub(%r|^build/|, '')
  unless remotepath == 'index.html'
    # Remove index.html from path for S3 bucket
    remotepath.sub!(%r|/index.html$|, '')
  end

  filelist[localpath] = remotepath
end

puts "Uploading: #{filelist.keys.count} files"



client = Aws::S3::Client.new(:region => 'eu-west-1')
bucket = Aws::S3::Bucket.new(
  'origin.radiodns.uk',
  :client => client
)

raise "Error: S3 bucket does not exist" unless bucket.exists?


# Upload each of the files
filelist.each_pair do |localpath,remotepath|
  suffix = File.extname(localpath)[1..-1].downcase.to_sym || :html
  puts "  => Uploading '#{localpath}' to '#{remotepath}' (#{suffix})"

  # Work out the MIME type for the file
  mime_type = MIME_TYPE_MAP[suffix]
  if mime_type.nil?
    $stderr.puts "Error: No MIME Type defined for '#{suffix}'" 
    next
  end

  File.open(localpath, 'rb') do |file|
    body = file.read
    
    if body.match(%r|<meta http-equiv=refresh content="0; url=(\S+)" />|)
      website_redirect_location = "https://www.radiodns.uk#{$1}"
    end

    bucket.put_object(
      :key => remotepath,
      :acl => 'public-read',
      :website_redirect_location => website_redirect_location,
      :content_type => mime_type,
      :cache_control => CACHE_CONTROL,
      :body => body
    )
  end
end


puts "Deleting unknown files from bucket"
bucket.objects.each do |obj|
  unless filelist.values.include?(obj.key)
    puts "  => #{obj.key}"
    obj.delete
  end
end

puts "Done."
