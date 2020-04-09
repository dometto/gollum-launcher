Minimal working example of a GUI Launcher for [Gollum](https://github.com/gollum/gollum) that can be used to generate a portable Java jar, using [Shoes 4](https://github.com/shoes/shoes4).

To run:

* `bundle install`
* `bundle exec jruby -J-XstartOnFirstThread lib/gollum_launcher.rb`

(` -J-XstartOnFirstThread` is needed only on OS X)

Uses gollum 4.x at present because `shoes 4` at present still [depends on a very old nokogiri](https://github.com/shoes/shoes4/issues/1579), which is incompatible with gollum 5.x.