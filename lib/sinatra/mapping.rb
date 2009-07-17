require 'sinatra/base'

# Informations about Sinatra DSL, please, visit the
# {official site}[http://www.sinatrarb.com/].
module Sinatra

  # This extension is useful for any Web application written using
  # Sinatra DSL. The main goal is help developers to write URL path
  # methods.
  module Mapping

    # Write URL path method for use in HTTP methods.
    #
    # The map method most be used by following syntax:
    #
    #   map <name>, <path>
    #
    # If name is equal :root, then returns path ended by slash "/".
    #
    #   map :root,    "tasks"       # => /tasks/
    #   map :changes, "last-changes # => /tasks/last-changes
    def map(name, path = nil)
      @locations ||= {}
      if name.to_sym == :root
        @locations[:root] = cleanup_paths("/#{path}/")
        metadef "#{name}_path" do |*paths|
          @locations[:root]
        end
      else
        @locations[name.to_sym] = path || name.to_s
        metadef "#{name}_path" do |*paths|
          map_path_to(@locations[name.to_sym], *paths)
        end
      end
    end

    # Returns URL path with query instructions.
    def query_path_to(*args)
      args.compact!
      query  = args.pop if args.last.kind_of?(Hash)
      path   = map_path_to(*args)
      path  << "?" << Rack::Utils::build_query(query) if query
      path
    end

  private

    # Check arguments. If argument is a symbol and exist map path before
    # setted, then return path mapped by symbol name.
    def map_path_to(*args)
      path_mapped(*locations_get_from(*args))
    end

    # Returns all paths mapped by root path in prefix.
    def path_mapped(*args)
      !args.empty? ? cleanup_paths("/#{@root_path}/#{args.join('/')}") : @root_root
    end

    # Get paths from location maps.
    def locations_get_from(*args)
      args.collect do |path|
        @locations.has_key?(path) ? @locations[path] : path
      end
    end

    # Clean all duplicated slashes.
    def cleanup_paths(*paths)
      paths.join('/').gsub(/[\/]{2,}/,'/')
    end

  end # module Mapping

  register Mapping

end # module Sinatra

