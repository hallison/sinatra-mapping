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
    def title_path(path, *args)
      title = (options.locations[path] || path).to_s.gsub('/',' ').strip
      title.gsub!(/\W/,' ') # Cleanup
      (args.empty? ? title : "#{title} #{args.join(' ')}").strip.capitalize
    end

    # Creates anchor links for name and extract path and HTML options from
    # arguments. Example:
    #
    #   # In Web application, add a map.
    #   map :status, "tasks/status"
    #
    #   get status_path do
    #     status = "finished"
    #     erb :status, :locals => { :status => status }
    #   end
    #
    #   # In status view, add a link to status map.
    #   <%= link_to "All finished", :status, status %>
    #   # => <a href="/tasks/status/finished">All finished</a>
    def link_to(name = nil, *args)
      options = args.last.kind_of?(Hash) ? args.pop : {}
      url     = args.shift if args.first.to_s =~ /^\w.*?:/
      "<a href=\"#{url || path_to(*args)}\" #{extract_tags_attributes(options)}>#{name || url}</a>"
    end

    def link_to_query(name, action, query = {}, options = {})
      "<a href=\"#{path_to(action,query)}\" #{extract_tags_attributes(options)}>#{name}</a>"
    end

    # Returns all paths with query parameters. Example:
    #
    #   # in Sinatra application:
    #   map :post, "articles"
    #   map :tags, "labels"
    #   # use the following instructions:
    #   path_to :tags, "ruby", :posts
    #   # returns "/labels/ruby/articles"
    def path_to(*args)
      options.build_path_to(env['SCRIPT_NAME'], *args)
    end

  private

    # Extract all tag attributes from a hash keys and values.
    def extract_tags_attributes(hash)
      hash.select do |key, value|
        [ :accesskey, :charset, :coords,
          :hreflang, :id, :lang,
          :name, :onblur, :onclick,
          :ondblclick, :onfocus, :onkeydown,
          :onkeypress, :onkeyup, :onmousedown,
          :onmousemove, :onmouseout, :onmouseover,
          :onmouseup, :rel, :rev,
          :shape, :style, :tabindex,
          :target, :title, :type ].include? key
      end.map do |attr, value|
        "#{attr}=\"#{value}\""
      end
    end

  end # module MappingHelpers

  helpers MappingHelpers

end # module Sinatra

