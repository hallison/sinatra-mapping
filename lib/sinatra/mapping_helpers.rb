module Sinatra

  # This module contains several helper methods for paths written using 
  # {map}[:link:./Sinatra/Mapping.html#map] method.
  module MappingHelpers

    # Creates a title using a path mapped. Otherwise, returns just arguments
    # joined by spaces and capitalised.
    def title_path(path, *args)
      title = (options.send("#{path}_path") || path).to_s.gsub('/',' ').strip
      title.gsub!(/\W/,' ') # Cleanup
      (args.empty? ? title : "#{title} #{args.join(' ')}").capitalize
    end

  end # module MapHelpers

end # module Sinatra

