
require File.expand_path('../../test_helper', __FILE__)

class ListCategoriesTest < Redmine::ApiTest::Base
  include KnowledgebaseApiTestHelper

  test "GET /categories.xml should contain metadata" do
    get_categories
    
    assert_select 'categories[type=array][total_count][limit="25"][offset="0"]'
  end

  test "GET /categories.xml with offset and limit" do
    get_categories(limit: 1, offset: 1)
    
    assert_select 'categories[type=array][total_count][limit="1"][offset="1"]'
    assert_select 'categories category', 1
  end

  def get_categories(params = {})
    url = '/projects/1/knowledgebase/categories.xml'
    url_params = params.map {|k, v| "#{k}=#{v}"}.join('&')
    url += "?#{url_params}" if url_params.present?
    get url, :headers => credentials('admin')
  end
end
