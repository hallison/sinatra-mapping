require 'sinatra/base'

# Informations about Sinatra DSL, please, visit the
# {official site}[http://www.sinatrarb.com/].
module Sinatra

  # This extension is useful for any Web application written using
  # Sinatra DSL. The main goal is help developers to write URL path
  # methods.
  module Mapping

    # All location paths mapped.
    attr_reader :locations

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
      @env       ||= {}
      @locations ||= {}
      if name.to_sym == :root
        @locations[:root] = cleanup_paths("/#{@env['SCRIPT_NAME']}/#{path}/")
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

    # Auto mapping from a hash. This method is very useful.
    # Example:
    #
    #   # In Web application.
    #   class WebApp << Sinatra::Base
    #     mapping :root   => "tasks",   # /tasks
    #             :status => "changes"  # /tasks/changes
    #   end
    #
    # Or, it's possible use from configuration file.
    #
    #   # YAML file "settings.yml".
    #   mapping:
    #     root: tasks
    #     status: changes
    #   # In Web application.
    #   class WebApp << Sinatra::Base
    #     mapping YAML.load_file("settings.yml")[:mapping]
    #   end
    def mapping(hash)
      hash.each do |name, path|
        map name, path
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
      !args.empty? ? cleanup_paths("/#{@locations[:root]}/#{args.join('/')}") : @locations[:root]
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

