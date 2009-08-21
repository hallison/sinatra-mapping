$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/..")

require 'rubygems'
require 'lib/sinatra/mapping'
require 'lib/sinatra/mapping_helpers'
require 'test/unit'
require 'rack/test'
require 'ruby-debug'

class Sinatra::Base
  def env
    @env ||= { 'SCRIPT_NAME' => '/blog' }
  end
end

class AppForTest < Sinatra::Base

  register Sinatra::Mapping
  helpers  Sinatra::MappingHelpers

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

  get posts_path "/" do
    redirect path_to(:posts), 301
  end

  get posts_path "/:year/:month/:day/:permalink" do |year, month, day, permalink|
    "#{title_path :posts}:" + path_to(:posts, "#{@date.to_s.gsub('-','/')}/#{permalink}")
  end

  get posts_path "/:year/:month/:day/:permalink/" do |year, month, day, permalink|
    redirect path_to(:posts, year, month, day, permalink), 301
  end

  get archive_path do
    "#{title_path :archive}:#{path_to :archive}"
  end

  get archive_path "/" do
    redirect path_to(:archive), 301
  end

  get archive_path "/:year/:month/:day/:permalink" do |year, month, day, permalink|
    "#{title_path :archive}:" + path_to(:archive, "#{@date.to_s.gsub('-','/')}/#{permalink}")
  end

  get archive_path "/:year/:month/:day/:permalink/" do |year, month, day, permalink|
    redirect path_to(:archive, year, month, day, permalink), 301
  end

  get about_path do
    "#{title_path :about}:#{path_to :about}"
  end

  get about_path "/" do
    redirect path_to(:about), 301
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

class TestMapping < Test::Unit::TestCase

  include Rack::Test::Methods

  def setup
    @date      = Date.today
    @locations = {
      :root_path    => "/blog/",
      :posts_path   => "/blog/articles",
      :archive_path => "/blog/archive/articles",
      :about_path   => "/blog/about",
      :search_path  => "/blog/find-articles",
      :drafts_path  => "/blog/unpublished"
    }
  end

  def app
    @app = ::AppForTest
    @app.set :environment, :test
    @app
  end

  def test_check_map_locations
    @locations.each do |name, location|
      assert_equal "#{location}", app.send(name)
    end
  end

  def test_should_return_ok_in_root_path
    get app.root_path do |response|
      assert response.ok?
      assert_equal "http://example.org#{@locations[:root_path]}", last_request.url
      assert_equal "Blog path:#{@locations[:root_path]}", response.body
    end
  end

  def test_should_return_ok_in_posts_path
    get app.posts_path do |response|
      assert response.ok?
      assert_equal "http://example.org#{@locations[:posts_path]}", last_request.url
      assert_equal "Articles published:#{@locations[:posts_path]}", response.body
    end

    get app.posts_path "/" do
      follow_redirect!
      assert last_response.ok?
      assert_equal "http://example.org#{@locations[:posts_path]}", last_request.url
    end

    path = app.posts_path "/#{@date.to_s.gsub('-','/')}/post-permalink"
    get path do |response|
      assert response.ok?
      assert_equal "http://example.org#{path}", last_request.url
      assert_equal "Articles:#{path}", response.body
    end

    get "#{path}/" do
      follow_redirect!
      assert last_response.ok?
      assert_equal "http://example.org#{path}", last_request.url
      assert_equal "Articles:#{path}", last_response.body
    end
  end

  def test_should_return_ok_in_archive_path
    get app.archive_path do |response|
      assert response.ok?
      assert_equal "http://example.org#{@locations[:archive_path]}", last_request.url
      assert_equal "Archive articles:#{@locations[:archive_path]}", response.body
    end

    get app.archive_path "/" do
      follow_redirect!
      assert last_response.ok?
      assert_equal "http://example.org#{@locations[:archive_path]}", last_request.url
    end

    path = app.archive_path "/#{@date.to_s.gsub('-','/')}/post-permalink"
    get path do |response|
      assert response.ok?
      assert_equal "http://example.org#{path}", last_request.url
      assert_equal "Archive articles:#{path}", response.body
    end

    get "#{path}/" do
      follow_redirect!
      assert last_response.ok?
      assert_equal "http://example.org#{path}", last_request.url
      assert_equal "Archive articles:#{path}", last_response.body
    end
  end

  def test_should_return_ok_in_about_path
    get app.about_path do |response|
      assert response.ok?
      assert_equal "http://example.org#{@locations[:about_path]}", last_request.url
      assert_equal "About:#{@locations[:about_path]}", response.body
    end

    get app.about_path "/" do
      follow_redirect!
      assert last_response.ok?
      assert_equal "http://example.org#{@locations[:about_path]}", last_request.url
    end
  end

  def test_should_return_ok_in_search_path
    get "#{app.search_path}?keywords=ruby" do |response|
      assert response.ok?
      assert_equal "http://example.org#{@locations[:search_path]}?keywords=ruby", last_request.url
      assert_equal "Find articles:#{@locations[:search_path]}?keywords=ruby", response.body.split("\n")[0]
      assert_equal "<a href=\"#{@locations[:search_path]}\" title=\"Search\">Search</a>", response.body.split("\n")[1]
      assert_equal "<a href=\"#{@locations[:search_path]}?keywords=ruby\" title=\"Search\">Search</a>", response.body.split("\n")[2]
    end
  end

  def test_should_check_path_method_with_array_params
    get "#{app.drafts_path}" do |response|
      assert response.ok?
      assert_equal "Unpublished:#{@locations[:drafts_path]}/articles", response.body.split("\n")[0]
      assert_equal "<a href=\"#{@locations[:drafts_path]}/articles\" title=\"Unpublished\">Unpublished</a>", response.body.split("\n")[1]
    end
  end
end

