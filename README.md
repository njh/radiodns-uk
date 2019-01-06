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


## Data Model

<img src="https://github.com/njh/radiodns-uk/blob/master/docs/data-model.png?raw=true" width="533" height="388" alt="Data Model Diagram" />

## Project Structure

These are the key files and directories that make up the project:

* `Gemfile` Used by [Bundler] to list all the dependencies for this project
* `Rakefile` parent [rake] file, describing build tasks. Run `rake -T` to list all the tasks
* `ansible` contains an [Ansible] playbook, used to deploy the application to the live server
* `app.rb` the main web server application and top level router
* `bin` various ruby scripts, used to generate the site
* `db.rb` this is used to initialise [Sequel] and sets the `DB` constant
* `genres` collection of JSON files, mapping [TV Anytime] genre IDs to genre names
* `helpers.rb` view helpers - methods to generate HTML to make the view code simpler
* `migrate` [Sequel] database migration files that create/update the database schema
* `models` directory containing the [Sequel] database models
* `models.rb` require this file to setup [Sequel] and load all the database models
* `public` static files served directly by the HTTP server
* `si_files` the various `SI.xml` files are downloaded to this directory
* `routes` directory containing route files (controllers) for main part of application
* `spec` Rspec files to run tests against the application and model code
* `tasks` directory containing [Rake] task files
* `views` [Erubi] templates for the the HTML and XML pages


## Development

You may need to install a recent version of [Ruby] on your computer before you can run the scripts.

To perform the geographic calculations on the transmitter locations, you also need Python 2.7 and the GDAL library.

To install GDAL on a Mac run:

    $ brew install gdal
    
To install GDAL on Debian/Ubuntu run:

    $ apt-get install python-gdal

Then make sure you have ruby [Bundler] installed:

    $ gem install bundler

And install all the dependencies:

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


[Ansible]:                   http://www.ansible.com/
[Bundler]:                   http://bundler.io/
[Erubi]:                     https://github.com/jeremyevans/erubi
[http://localhost:9393/]:    http://localhost:9393/
[MIT License]:               http://opensource.org/licenses/MIT
[Ofcom]:                     https://www.ofcom.org.uk/
[radiodns.uk]:               http://www.radiodns.uk/
[RadioDNS]:                  http://www.radiodns.org/
[Rake]:                      https://github.com/ruby/rake
[Roda]:                      http://roda.jeremyevans.net/
[Ruby]:                      http://ruby-lang.org/
[Sequel]:                    http://sequel.jeremyevans.net/
[Transmitter Parameters]:    https://www.ofcom.org.uk/spectrum/information/radio-tech-parameters
[TV Anytime]:                http://www.tv-anytime.org/
