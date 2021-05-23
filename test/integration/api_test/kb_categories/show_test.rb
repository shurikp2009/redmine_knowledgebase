
require File.expand_path('../test_helper', __FILE__)

class ShowCategoryTest < Redmine::ApiTest::Base
  include KnowledgebaseApiTestHelper
  
  test "GET /categories/:id.xml" do
    get '/projects/1/knowledgebase/categories/1.xml', :headers => credentials('admin')
    assert_select 'category id', text: '1'
    assert_select 'category title', text: 'MyString'
  end
end
