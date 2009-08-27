require 'sinatra/base'

# Informations about Sinatra DSL, please, visit the
# {official site}[http://www.sinatrarb.com/].
module Sinatra

# Copyright (c) 2009 Hallison Batista
#
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
  #   map :root,    "tasks"       #=> /tasks/
  #   map :changes, "last-changes #=> /tasks/last-changes
  def map(name, path = nil)
    @locations ||= {}
    if name.to_sym == :root
      @locations[:root] = cleanup_paths("/#{path}/")
      metadef "#{name}_path" do |*paths|
        cleanup_paths("/#{@locations[:root]}/?")
      end
    else
      @locations[name.to_sym] = cleanup_paths(path || name.to_s)
      metadef "#{name}_path" do |*paths|
        map_path_to(@locations[name.to_sym], *paths << "/?")
      end
    end
    Delegator.delegate "#{name}_path"
  end

  # Auto mapping from a hash. This method is very useful.
  # Example:
  #
  # In Web application:
  #
  #   class WebApp << Sinatra::Base
  #     mapping :root   => "tasks",   # /tasks
  #             :status => "changes"  # /tasks/changes
  #   end
  #
  # Or, it's possible use from configuration file.
  #
  #   # YAML file "mapping.yml".
  #   root: tasks
  #   status: changes
  #
  #   # In Sinatra application.
  #
  #   mapping YAML.load_file("mapping.yml")
  #   #=> root_path   # /tasks
  #   #=> status_path # /tasks/changes
  def mapping(hash)
    hash.each do |name, path|
      map name, path
    end
  end

  # Register automatically all helpers in base application.
  def self.registered(app)
    app.helpers Mapping::Helpers
  end

private

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

  # Check arguments. If argument is a symbol and exist map path before
  # setted, then return path mapped by symbol name.
  def map_path_to(*args)
    script_name = args.shift if args.first.to_s =~ %r{^/\w.*}
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

  # Copyright (c) 2009 Hallison Batista
  #
  # This module contains several helper methods for paths written using 
  # +map+ method.
  module Helpers

    # Creates a title using a path mapped. Otherwise, returns just arguments
    # joined by spaces and capitalised.
    #
    # In Sinatra application:
    #
    #   map :posts,   "articles"
    #   map :tags,    "labels"
    #   map :archive, "archive/articles"
    #
    # In views:
    #
    #   <%=title_path :posts%>
    #   #=> "Articles"
    #
    #   <%=title_path :tags%>
    #   #=> "Labels"
    #
    #   <%=title_path :archive%>
    #   #=> "Archive articles"
    def title_path(path, *args)
      title = (options.locations[path] || path).to_s.gsub('/',' ').strip
      title.gsub!(/\W/,' ') # Cleanup
      (args.empty? ? title : "#{title} #{args.join(' ')}").strip.capitalize
    end

    # Creates anchor links for name and extract path and HTML options from
    # arguments. Example:
    #
    # In Sinatra application, add a map.
    #
    #   map :tasks,  "tasks"
    #   map :status, "tasks/status"
    #
    #   get tasks_path do
    #     erb :tasks, :locals => { :name => params.values.join(', ') }
    #   end
    #
    #   get status_path do
    #     erb :status, :locals => { :status => "finished" }
    #   end
    #
    # In status view, add a link to status map.
    #
    #   <%= link_to "All finished", :status, status %>
    #   #=> <a href="/tasks/status/finished">All finished</a>
    #
    #   <%= link_to "All finished", :status, :name => status %>
    #   #=> <a href="/tasks/status?name=finished">All finished</a>
    def link_to(name = nil, *args)
      options = args.last.kind_of?(Hash) ? args.pop : {}
      url     = args.shift if args.first.to_s =~ /^\w.*?:/
      args   << extract_query_attributes(options)
      "<a href=\"#{url || path_to(*args)}\"#{extract_link_attributes(options)}>#{name || url}</a>"
    end

    # Returns all paths with query parameters. Example:
    #
    # In Sinatra application:
    #
    #   map :post, "articles"
    #   map :tags, "labels"
    #
    # Use the following instructions:
    #
    #   path_to :tags, "ruby", :posts
    #   #=> "/labels/ruby/articles"
    def path_to(*args)
      self.class.send(:build_path_to, env['SCRIPT_NAME'], *args)
    end

  private

    # Extract all tag attributes from a hash keys and values.
    def extract_link_attributes(hash)
      select_link_attributes(hash).map do |attribute, value|
        " #{attribute}=\"#{value}\""
      end
    end

    # Returns only attributes for link tag.
    def select_link_attributes(hash)
      hash.select{ |key, value| link_attributes.include?key }
    end

    # Select all keys and values that not included in link attributes.
    def extract_query_attributes(hash)
      query = hash.select{ |key, value| !link_attributes.include?key }.flatten
      Hash[*query] unless query.empty?
    end

    # Attribute list for link tag.
    def link_attributes
      [:accesskey, :charset, :coords, :hreflang, :id, :lang, :name, :onblur,
      :onclick, :ondblclick, :onfocus, :onkeydown, :onkeypress, :onkeyup,
      :onmousedown, :onmousemove, :onmouseout, :onmouseover, :onmouseup,
      :rel, :rev, :shape, :style, :tabindex, :target, :title, :type]
    end

  end # module Helpers

end # module Mapping

register Mapping

end # module Sinatra

