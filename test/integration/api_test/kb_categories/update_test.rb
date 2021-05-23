
require File.expand_path('../test_helper', __FILE__)

class UpdateCategoryTest < Redmine::ApiTest::Base
  include KnowledgebaseApiTestHelper

  test "PUT /categories/:id.xml should update an article with the attributes" do
    new_title = 'Updated title'
    put(
      "/projects/1/knowledgebase/categories/1.xml",
      :params => {:category => {:title => new_title}},
      :headers => credentials('admin'))
    
    assert_category_updated(title: new_title)
  end

  test "PUT /categories/:id.json should update an article with the attributes" do
    new_title = 'Updated title'
    put(
      "/projects/1/knowledgebase/categories/1.json",
      :params => {:category => {:title => new_title}},
      :headers => credentials('admin'))
    
    assert_category_updated(title: new_title)
  end

  def assert_category_updated(params, category_id = 1)
    category = KbCategory.find(category_id)

    params.each do |k, v|
      assert_equal(v, category.send(k))
    end
  end
end
