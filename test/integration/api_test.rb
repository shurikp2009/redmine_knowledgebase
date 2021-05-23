require File.dirname(__FILE__) + '/../test_helper'

class ApiTest < Redmine::ApiTest::Base
  # fixtures :users, :email_addresses, :members, :member_roles, :roles, :projects
  fixtures :projects, :roles, :users
  plugin_fixtures :kb_articles, :enabled_modules

  def test_json_article_list
    get '/kb_articles.json', :headers => credentials('admin')
    assert_response :success
  end
end
