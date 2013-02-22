module CubaApi
  class Reloader

    def self.parse( basedir, baseconstant )
      Dir[ File.join( basedir, '**', '*.rb' ) ].each do |f| 
        last_modified = File.mtime( f ).to_f
        if ! File.directory?( f ) && last_modified > @max_last_modified.to_f
          @max_last_modified = last_modified
          yield f
        end
      end
    end

    def self.maybe_remove_constant( f, basedir, baseconstant )
      c = baseconstant
      cname = nil
      f.sub( /#{basedir}/, '' ).split( /\/|\./ ).each do |name|
        if name != 'rb'
          ( c = c.const_get( cname ) ) rescue nil
          cname = name.split('_').each { |a| a.capitalize! }.join.to_sym
        end
      end
      c.send( :remove_const, cname ) rescue nil
    end
    
    def self.doit( basedir, baseconstant )
      if @max_last_modified
        parse( basedir, baseconstant ) do |f|
          maybe_remove_constant( f, basedir, baseconstant )
          puts "[CubaAPI::Reloader] #{f}: #{load f}"
        end
      else
        parse( basedir, baseconstant ) {}
      end
    end
  end

  class ReloaderRack
    def initialize( app, basedir, baseconstant)
      @app = app
      @basedir = basedir
      @baseconstant = baseconstant
    end

    def call(env)
      Reloader.doit( @basedir, @baseconstant )
      status, headers, body = @app.call(env)
    end
  end
end
