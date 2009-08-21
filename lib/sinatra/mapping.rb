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
    #
    #   # In Sinatra application.
    #   mapping YAML.load_file("settings.yml")[:mapping]
    #   # root_path   # /tasks
    #   # status_path # /tasks/changes
    def mapping(hash)
      hash.each do |name, path|
        map name, path
      end
    end

    # Returns URL path with query instructions.
    # This method has been extracted from
    # http://wiki.github.com/sinatra/sinatra/howto-generate-links.
    def build_path_to(script_name = nil, *args)
      args.compact!
      query = args.pop if args.last.kind_of?(Hash)
      path  = map_path_to(script_name, *args)
      path << "?" << Rack::Utils::build_query(query) if query
      path
    end

  private

    # Check arguments. If argument is a symbol and exist map path before
    # setted, then return path mapped by symbol name.
    def map_path_to(*args)
      script_name = args.shift if args.first.to_s =~ /^\/\w.*/
      path_mapped(script_name, *locations_get_from(*args))
    end

    # Returns all paths mapped by root path in prefix.
    def path_mapped(script_name, *args)
      return cleanup_paths("/#{script_name}/#{@locations[:root]}") if args.empty?
      cleanup_paths("/#{script_name}/#{@locations[:root]}/#{args.join('/')}")
    end

    # Get paths from location maps.
    def locations_get_from(*args)
      args.flatten.reject do |path|
        path == :root
      end.collect do |path|
        @locations[path] || path
      end
    end

    # Clean all duplicated slashes.
    def cleanup_paths(*paths)
      #.gsub(%r{#{@locations[:root]}/#{@locations[:root]}}, @locations[:root])
      paths.join('/').gsub(/[\/]{2,}/,'/')
    end

  end # module Mapping

  register Mapping

end # module Sinatra

