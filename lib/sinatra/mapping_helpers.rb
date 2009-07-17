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
      title = (options.send("#{path}_path") || path).to_s.gsub('/',' ').strip
      title.gsub!(/\W/,' ') # Cleanup
      (args.empty? ? title : "#{title} #{args.join(' ')}").capitalize
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
      options.query_path_to(*args)
    end

  end # module MapHelpers

end # module Sinatra

