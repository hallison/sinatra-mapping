$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/..")

require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'ruby-debug'

require 'test/fixtures/modular_application'

class ModularTestMapping < Test::Unit::TestCase

  include Rack::Test::Methods

  def setup
    @date = Date.today
    @link_paths = {
      :root_path    => "/test/blog",
      :posts_path   => "/test/blog/articles",
      :archive_path => "/test/blog/archive/articles",
      :about_path   => "/test/blog/about",
      :search_path  => "/test/blog/find-articles",
      :drafts_path  => "/test/blog/unpublished"
    }
    @root_paths = @link_paths.inject({}) do |hash, (name, path)|
      hash[name] = "#{path}/"
      hash
    end
    @paths = @root_paths.inject({}) do |hash, (name, path)|
      hash[name] = "#{path}?"
      hash
    end
  end

  def app
    @app = ::ModularApplication
    @app.set :environment, :test
    @app
  end

  def test_check_map_locations
    @paths.each do |name, location|
      path = location.gsub(/\/test/,'')
      assert_equal path, app.send(name)
    end
  end

  def test_should_return_ok_in_root_path
    get app.root_path do |response|
      assert response.ok?
      assert_equal "http://example.org#{@root_paths[:root_path]}", last_request.url
      assert_equal "Blog path:#{@link_paths[:root_path]}/", response.body
    end
  end

  def test_should_return_ok_in_posts_path
    get app.posts_path do |response|
      assert response.ok?
      assert_equal "http://example.org#{@root_paths[:posts_path]}", last_request.url
      assert_equal "Articles published:#{@link_paths[:posts_path]}", response.body
    end

    path_id = "#{@date.to_s.gsub('-','/')}/post-permalink"
    get app.posts_path path_id do |response|
      assert response.ok?
      assert_equal "http://example.org#{@root_paths[:posts_path]}#{path_id}/", last_request.url
      assert_equal "Articles:#{@link_paths[:posts_path]}/#{path_id}", response.body
    end
  end

  def test_should_return_ok_in_archive_path
    get app.archive_path do |response|
      assert response.ok?
      assert_equal "http://example.org#{@root_paths[:archive_path]}", last_request.url
      assert_equal "Archive articles:#{@link_paths[:archive_path]}", response.body
    end

    path_id =  "#{@date.to_s.gsub('-','/')}/post-permalink"
    get app.archive_path path_id do |response|
      assert response.ok?
      assert_equal "http://example.org#{@root_paths[:archive_path]}#{path_id}/", last_request.url
      assert_equal "Archive articles:#{@link_paths[:archive_path]}/#{path_id}", response.body
    end
  end

  def test_should_return_ok_in_about_path
    get app.about_path do |response|
      assert response.ok?
      assert_equal "http://example.org#{@root_paths[:about_path]}", last_request.url
      assert_equal "About:#{@link_paths[:about_path]}", response.body
    end
  end

  def test_should_return_ok_in_search_path
    path_params = "keywords=ruby"
    get app.search_path, :keywords => "ruby" do |response|
      assert response.ok?
      assert_equal "http://example.org#{@root_paths[:search_path]}?keywords=ruby", last_request.url
      assert_equal "Find articles:#{@link_paths[:search_path]}?keywords=ruby", response.body.split("\n")[0]
      assert_equal "<a href=\"#{@link_paths[:search_path]}\" title=\"Search\">Search</a>", response.body.split("\n")[1]
      assert_equal "<a href=\"#{@link_paths[:search_path]}?keywords=ruby\" title=\"Search\">Search</a>", response.body.split("\n")[2]
    end
  end

  def test_should_check_path_method_with_array_params
    get app.drafts_path do |response|
      assert response.ok?
      assert_equal "Unpublished:#{@link_paths[:drafts_path]}/articles", response.body.split("\n")[0]
      body_link = "<a href=\"#{@link_paths[:drafts_path]}/articles\" title=\"Unpublished\">Unpublished</a>"
      assert_equal body_link, response.body.split("\n")[1]
    end
  end
end

