$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../../lib/")

require 'rubygems'
require 'sinatra/base'
require 'sinatra/mapping'

class Sinatra::Base
  def env
    @env.update('SCRIPT_NAME' => '/test')
  end
end

class ModularApplication < Sinatra::Base

  register Sinatra::Mapping

  map :root,  "blog"   # root_path    => /blog/
  map :about           # about_path   => /blog/about

  mapping :posts   => "articles",         # posts_path   => /blog/articles
          :archive => "archive/articles", # archive_path => /blog/archive/articles
          :search  => "find-articles",    # search_path  => /blog/find-articles
          :drafts  => "unpublished"       # drafts_path  => /blog/unpublished

  before do
    @date = Date.today
  end

  get root_path do
    "#{title_path :root, :path}:#{path_to :root}"
  end

  get posts_path do
    "#{title_path :posts, :published}:#{path_to :posts}"
  end

  get posts_path "/:year/:month/:day/:permalink" do |year, month, day, permalink|
    "#{title_path :posts}:" + path_to(:posts, "#{@date.to_s.gsub('-','/')}/#{permalink}")
  end

  get archive_path do
    "#{title_path :archive}:#{path_to :archive}"
  end

  get archive_path "/:year/:month/:day/:permalink" do |year, month, day, permalink|
    "#{title_path :archive}:" + path_to(:archive, "#{@date.to_s.gsub('-','/')}/#{permalink}")
  end

  get about_path do
    "#{title_path :about}:#{path_to :about}"
  end

  get search_path do
    <<-end_content.gsub(/^      /,'')
      #{title_path :search}:#{path_to :search, :keywords => 'ruby'}
      #{link_to "Search", :search, :title => 'Search'}
      #{link_to "Search", :search, :title => 'Search', :keywords => 'ruby'}
    end_content
  end

  get drafts_path do
    <<-end_content.gsub(/^      /,'')
      #{title_path :drafts}:#{path_to [:drafts, :posts]}
      #{link_to "Unpublished", :drafts, :posts, :title => 'Unpublished'}
    end_content
  end

end

