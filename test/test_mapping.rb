$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/..")

require 'rubygems'
require 'lib/sinatra/mapping'
require 'lib/sinatra/mapping_helpers'
require 'test/unit'
require 'rack/test'
require 'ruby-debug'

class AppForTest < Sinatra::Base

  register Sinatra::Mapping

  map :root                        # root_path    => /
  map :posts,   "articles"         # posts_path   => /articles
  map :archive, "archive/articles" # archive_path => /articles/archive
  map :about                       # about_path   => /about

  helpers Sinatra::MappingHelpers

  before do
    @date = Date.today
  end

  get root_path do
    "#{title_path :root}:#{options.root_path}"
  end

  get posts_path do
    "#{title_path :posts}:#{options.posts_path}"
  end

  get posts_path "/" do
    redirect options.posts_path, 301
  end

  get posts_path "/:year/:month/:day/:permalink" do |year, month, day, permalink|
    "#{title_path :posts}:" + options.posts_path("#{@date.to_s.gsub('-','/')}/#{permalink}")
  end

  get posts_path "/:year/:month/:day/:permalink/" do |year, month, day, permalink|
    redirect options.posts_path(year, month, day, permalink), 301
  end

  get archive_path do
    "#{title_path :archive}:#{options.archive_path}"
  end

  get archive_path "/" do
    redirect options.archive_path, 301
  end

  get archive_path "/:year/:month/:day/:permalink" do |year, month, day, permalink|
    "#{title_path :archive}:" + options.archive_path("#{@date.to_s.gsub('-','/')}/#{permalink}")
  end

  get archive_path "/:year/:month/:day/:permalink/" do |year, month, day, permalink|
    redirect options.archive_path(year, month, day, permalink), 301
  end

  get about_path do
    "#{title_path :about}:#{options.about_path}"
  end

  get about_path "/" do
    redirect options.about_path, 301
  end

end

class TestMapping < Test::Unit::TestCase

  include Rack::Test::Methods

  def setup
    @date      = Date.today
    @locations = {
      :root_path    => "/",
      :posts_path   => "/articles",
      :archive_path => "/archive/articles",
      :about_path   => "/about"
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
    get "#{@locations[:root_path]}" do |response|
      assert response.ok?
      assert_equal "http://example.org#{@locations[:root_path]}", last_request.url
      assert_equal ":#{@locations[:root_path]}", response.body
    end
  end

  def test_should_return_ok_in_posts_path
    get "#{@locations[:posts_path]}" do |response|
      assert response.ok?
      assert_equal "http://example.org#{@locations[:posts_path]}", last_request.url
      assert_equal "Articles:#{@locations[:posts_path]}", response.body
    end

    get "#{@locations[:posts_path]}/" do
      follow_redirect!
      assert last_response.ok?
      assert_equal "http://example.org#{@locations[:posts_path]}", last_request.url
    end

    path = "#{@locations[:posts_path]}/#{@date.to_s.gsub('-','/')}/post-permalink"
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
    get "#{@locations[:archive_path]}" do |response|
      assert response.ok?
      assert_equal "http://example.org#{@locations[:archive_path]}", last_request.url
      assert_equal "Archive articles:#{@locations[:archive_path]}", response.body
    end

    get "#{@locations[:archive_path]}/" do
      follow_redirect!
      assert last_response.ok?
      assert_equal "http://example.org#{@locations[:archive_path]}", last_request.url
    end

    path = "#{@locations[:archive_path]}/#{@date.to_s.gsub('-','/')}/post-permalink"
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
    get "#{@locations[:about_path]}" do |response|
      assert response.ok?
      assert_equal "http://example.org#{@locations[:about_path]}", last_request.url
      assert_equal "About:#{@locations[:about_path]}", response.body
    end

    get "#{@locations[:about_path]}/" do
      follow_redirect!
      assert last_response.ok?
      assert_equal "http://example.org#{@locations[:about_path]}", last_request.url
    end
  end
end

