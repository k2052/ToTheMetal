# Setting up a ruby dev env

`rbenv versions`

`rbenv global ruby-2.0.0.-p0`

`gem install bundler`

Run into issues?

`gem --verbose`

```sh
wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh
```

I don't know about you but I'm worried about this fracking up my git. Heroku and foreman are gems but git is a package and I don't want two install so let us see what is inside.

```sh
curl https://toolbelt.heroku.com/install-ubuntu.sh
```

By default curl outputs to stdout. The it looks like it just adds the heroku-toolbelt repo and then does and apt-get install. Which means dependencies will be hanlded correctly. Never trust any auhtority always check if something feels like it could break. Better safe than exploded.

```sh
heroku login
```

Get your keys to heroku

```sh
xclip -sel clip < ~/.ssh/id_rsa.pub
firefox-trunk 'https://dashboard.heroku.com/account'
```

Add new ssh key via coyp + paste

Delight:
	rbenv works without sudo. When a command says `sudo gem install` ignor the sudo bit.
	You can see this by running `ruby -v` and `sudo ruby -v`.
	If you need sudo (you really should avoid it. if you think you need it you probably don't.)
	there are rbenv sudo shims that work similar to how RVM achieves sudo support.

	Here is one [rbenv-sudo[(https://github.com/dcarley/rbenv-sudo)

	When running `sudo` on rbenv you may see something like:

	```sh
		ERROR: Failed to build gem native extension.

        /usr/bin/ruby1.9.1 extconf.rb
/usr/lib/ruby/1.9.1/rubygems/custom_require.rb:36:in `require': cannot load such file -- mkmf (LoadError)
	```

	That is telling you to drop the sudo. Drop it.


## Foreman Guide
