cuba-api
========

* [![Build Status](https://secure.travis-ci.org/mkristian/cuba-api.png)](http://travis-ci.org/mkristian/cuba-api)
* [![Dependency Status](https://gemnasium.com/mkristian/cuba-api.png)](https://gemnasium.com/mkristian/cuba-api)
* [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/mkristian/cuba-api)

these are just a handful for [cuba](https://github.com/soveran/cuba) to use cuba as API server.

security
--------

cuba-api installs the **safe_yaml** gem and will use it when you accept yaml input. installing **safe_yaml** is a bit invasiv, but better be on the safe side of things.

cuba\_-api/config.rb
------------------

this plugin adds configuration to cuba which inherits from its superclass. this is very similar to `Cuba.settings`.

the short comng of `Cuba.settings`are

* data needs to be marshalable, i.e. needs Marshal.load(Marshal.dump(obj)) to work

* inheritence takes place on class parsing. when you first require all your **cubas** and then set your settings in the root **cuba** then the children will not see this settings. set the data like this

    CubaAPI[ :mykey ] = "mydata"
    puts CubaAPI[ :mykey ]

cuba\_api/write_aspect.rb 
-------------------------

first you write out response data with `write( data, options )` instead of using the response object from cuba. then a plugin can register an aspect which is basically a method which has the same arguments as write. now write will call each of the aspects using the result of the aspect as new data object, i.e. chaining those aspects.

cuba\_api/serializer.rb 
-------------------------

aspect which wraps the data object into a serializer which has `to_json`, `to_yaml` and `to_xml` as configured. see also [ixtlan-babel](https://github.com/mkristian/ixtlan-babel). to configure these methods just **require 'json'** or **require 'yaml'** or any xml lbrary which offers a `to_xml` method on the `Hash` class. dito use an json library which does offer `to_json` on `Hash`.

cuba\_api/accept_content.rb 
----------------------------

this aspect looks first at the file extension of the path part of the uri and the on request header **Accept** to determine the content type the response shall deliver. it will set the respective content-type as well calls `to_json`, '`to_yaml` or `to_xml` respectively. this aspect plays well with a preceeding serializer aspect ;)


cuba\_api/current_user.rb 
--------------------------

some helper methods to manage a current_user n the session. needs a session-manager in `CubaAPI[ :sessions ]` which respond to `to_session( user_object )` and `from_session( session_data )`. could be something like

    class SessionManager
	  def to_session( user_object ) user_object.id; end
	  def from_session( session_data ) User.find_by_id( hash_data ); end
	end


cuba\_api/guard.rb 
--------------------------

simple authorization which assumes a user belongs to many groups and group has a name attribute. now the cuba "routing" can use this

    on allowed?( :root, :admin ), get, 'configuration' do 
	   # retrieve configuration allowed by root and admin
    end

    on allowed?( :root ), put, 'configuration' do 
	   # update configuration only allowed by root
    end

Pending
-------

request payload needs to parse from json, yaml or xml into a hash.

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

meta-fu
-------

enjoy :) 

