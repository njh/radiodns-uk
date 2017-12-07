RadioDNS.uk
===========

This is the code repository that generates the [radiodns.uk] website, a directory
listing of all the radio stations in the United Kingdom which have [RadioDNS] Hybrid Radio
services available

It is a statically generated website, with the HTML built and deployed using [Ruby] and [Middleman].


The steps to generate the site are:

1. Download the [Transmitter Parameters] spreadsheet from Ofcom
2. Convert the Transmitter Parameters spreadsheet to a JSON document
3. For each service on FM and DAB, lookup the Authoritative FQDN using radiodns.org
4. For each Authoritative FQDN, attempt to download the Service Information (SI.xml) file
5. Generate a webpage for each service listed in the Service Information files



## Development

You may need to install a recent version of [Ruby] on your computer before you can run the scripts.

First make sure you have [Bundler] installed:

    $ gem install bundler

Then install all the dependencies:

    $ bundle install

To build a copy of the website on your local machine run:

    $ rake build

This will download the required data, and generate all the HTML files.

You can then run a web-server locally on your machine to view the site:

    $ rake server

And then open the following URL in your browser: [http://localhost:3000/]


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/njh/radiodns-uk.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License].



[radiodns.uk]:               http://www.radiodns.uk/
[RadioDNS]:                  http://www.radiodns.org/
[MIT License]:               http://opensource.org/licenses/MIT
[Transmitter Parameters]:    https://www.ofcom.org.uk/spectrum/information/radio-tech-parameters
[Ruby]:                      http://ruby-lang.org/
[Bundler]:                   http://bundler.io/
[Middleman]:                 https://middlemanapp.com/
[http://localhost:3000/]:    http://localhost:3000/
