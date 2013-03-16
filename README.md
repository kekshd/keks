KeKs is a common Rails application and may be installed like any other Rails app. The project is currently available in German only. The following describes one way to set it up on Debian stable.

### general details
The project setup…
- is written in Rails 3.2
- uses Ruby API Level 1.9.1+
- uses Thin as its server and connects via loopback to the outside world
- uses Debian’s Ruby
- uses a local gem setup


### required packages
for production: `ruby1.9.1 graphviz texlive-base texlive-latex-base texlive-latex-recommended texlive-fonts-extra texlive-latex-extra libxml2-dev libxslt-dev ruby1.9.1-dev`

### getting ruby and gems to work
I assume KeKs is being run as its own user. To avoid having to set the path to Ruby manually each time, modify your shell-rc file to include
```
alias ruby="/usr/bin/ruby1.9.1"
alias gem="/usr/bin/gem1.9.1"
```
If you don’t want to install gems globally, also decide on a path where the gems should be installed. Say the gem install path should be`/srv/keks/GEMS` then add this to your shell-rc file as well:
```
export PATH=/srv/keks/GEMS/bin:$PATH
export GEM_HOME=/srv/keks/GEMS
export GEM_PATH=/srv/keks/GEMS
```
To verify it works, run `ruby -v`. It should print something like `ruby 1.9.2p0 (2010-08-18 revision 29036) [x86_64-linux]`.

You also need bundler to install all the dependencies for you. Install it by running `gem install bundler`. If everything is setup up correctly you should be able to type `bundle help` and see its man page. Note the spelling: the executable is without `r` while the gem name includes it.


### setting it up
- clone the repository
- run `bundle install`
- adjust URLs in: `config/environments/production.rb` (absolute URLs when sending mails) and `app/views/main/help.html.erb` (“Fachschaft”)
- adjust mail address. It’s used in several places, so just grep for `keks@uni-hd.de`.
- `rake db:migrate`
- If your setup works, running `rails server` in the console should spawn a server at `http://localhost:3000` with KeKs. If you have problems, try `bundle exec rails server` instead.

Note you need to be in production mode in order for the sub-URI magic to work.

On each update run `rake assets:precompile` to recompile the JS or CSS files. Similarly run `rake db:migrate` to incorporate changes into the DB.

### connecting it to the outside world
`cat /etc/apache2/sites-available/keks`
```
 # don’t forget to set in config/environments/production.rb too

 ProxyPass /keks/ http://localhost:3000/
 ProxyPassReverse /keks/ http://localhost:3000/
```

Run `sudo a2ensite keks` to enable or disable the reverse proxy. If you plan to deploy it to a sub-URI (e.g. `yoursite.com/keks123/`) you need to let know Rails know about this before starting the server. For the example, this would look like this: `export RAILS_RELATIVE_URL_ROOT=/keks123 rails server`


### handling reboots

For Debian stable the best approach is probably using an init file and start-stop-daemon to manage the server. You can find an example in `initscript-example`. Adjust the paths, copy it to `/etc/init.d/` and make it executable. The filename should be the same as given in the “Provides:” directive on top of the file. That’ll be `keks` most likely.
