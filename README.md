RadioDNS.uk
===========

This is the code repository that powers the [radiodns.uk] website. The website is a directory
listing of all the radio stations in the United Kingdom which have [RadioDNS] Hybrid Radio
services available. Transmitter and DAB multiple information comes from [Ofcom].

The website written in [Ruby] and uses the [Sequel] and [Roda] gems.


The steps to build the site are:

1. Load the list of TV Anytime genre files into the database
2. Load the [Transmitter Parameters] spreadsheet from Ofcom into the database
3. For each service on FM and DAB, lookup the Authoritative FQDN using radiodns.org
4. For each Authoritative FQDN, attempt to load the Service Information (SI.xml) file



## Development

You may need to install a recent version of [Ruby] on your computer before you can run the scripts.

First make sure you have [Bundler] installed:

    $ gem install bundler

Then install all the dependencies:

    $ bundle install

To initialise the database run:

    $ bundle exec rake db:migrate

Then fill it up with data using:

    $ bundle exec rake load:all

Run `rake -T` to see a list of the individual tasks:

    $ bundle exec rake -T
    rake clean             # Deleted all the generated files (based on .gitignore)
    rake db:annotate       # Annotate Sequel models
    rake db:migrate        # Migrate database to latest version
    rake load:all          # Load all data into the database
    rake load:authorities  # Load authority information for each bearer from ra...
    rake load:genres       # Load TVA genre data into the database
    rake load:ofcom        # Load Ofcom data into the database
    rake load:si           # Load SI files into the database
    rake publish           # Publish the local SQLite database to the web server
    rake spec              # Run RSpec code examples

You can then run a local webserver using:

    $ bundle exec shotgun
    
Shotgun will reload the application after every request, which makes development much easier.

And then open the following URL in your browser: [http://localhost:9393/]


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/njh/radiodns-uk.
This project is intended to be a safe and welcoming space for collaboration. Contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License].



[Bundler]:                   http://bundler.io/
[MIT License]:               http://opensource.org/licenses/MIT
[Ofcom]:                     https://www.ofcom.org.uk/
[radiodns.uk]:               http://www.radiodns.uk/
[RadioDNS]:                  http://www.radiodns.org/
[Roda]:                      http://roda.jeremyevans.net/
[Ruby]:                      http://ruby-lang.org/
[Sequel]:                    http://sequel.jeremyevans.net/
[Transmitter Parameters]:    https://www.ofcom.org.uk/spectrum/information/radio-tech-parameters
[http://localhost:9393/]:    http://localhost:9393/
