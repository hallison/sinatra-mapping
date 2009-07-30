module Sinatra

  # This module contains several helper methods for paths written using 
  # {map}[:link:./Sinatra/Mapping.html#map] method.
  #
  # For use this helper, add the following syntax in application source:
  #
  #   register Sinatra::MappingHelpers
  module MappingHelpers

    # Creates a title using a path mapped. Otherwise, returns just arguments
    # joined by spaces and capitalised.
    #
    #   # In Sinatra application
    #
    #   map :posts,   "articles"
    #   map :tags,    "labels"
    #   map :archive, "archive/articles"
    #
    #   # In views
    #
    #   <%=title_path :posts%>
    #   # => "Articles"
    #
    #   <%=title_path :tags%>
    #   # => "Labels"
    #
    #   <%=title_path :archive%>
    #   # => "Archive articles"
    def title_path(path, *args)
      title = (options.locations[path] || path).to_s.gsub('/',' ').strip
      title.gsub!(/\W/,' ') # Cleanup
      (args.empty? ? title : "#{title} #{args.join(' ')}").strip.capitalize
    end

    # Creates anchor links for name and extract path and HTML options from
    # arguments. Example:
    #
    #   # In Sinatra application, add a map.
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
    #   # In status view, add a link to status map.
    #
    #   <%= link_to "All finished", :status, status %>
    #   # => <a href="/tasks/status/finished">All finished</a>
    #
    #   <%= link_to "All finished", :status, :name => status %>
    #   # => <a href="/tasks/status?name=finished">All finished</a>
    def link_to(name = nil, *args)
      options = args.last.kind_of?(Hash) ? args.pop : {}
      url     = args.shift if args.first.to_s =~ /^\w.*?:/
      args   << extract_query_attributes(options)
      "<a href=\"#{url || path_to(*args)}\"#{extract_link_attributes(options)}>#{name || url}</a>"
    end

    # Returns all paths with query parameters. Example:
    #
    #   # In Sinatra application:
    #
    #   map :post, "articles"
    #   map :tags, "labels"
    #
    #   # Use the following instructions:
    #
    #   path_to :tags, "ruby", :posts
    #   # => "/labels/ruby/articles"
    def path_to(*args)
      options.build_path_to(env['SCRIPT_NAME'], *args)
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

  end # module MappingHelpers

  helpers MappingHelpers

end # module Sinatra

