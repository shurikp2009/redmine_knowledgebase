
require File.expand_path('../../test_helper', __FILE__)

class UpdateCategoryTest < Redmine::ApiTest::Base
  include KnowledgebaseApiTestHelper

  test "PUT /categories/:id.xml should update a category with the attributes" do
    new_title = 'Updated title'
    put(
      "/projects/1/knowledgebase/categories/1.xml",
      {:category => {:title => new_title}},
      credentials('admin'))
    
    assert_category_updated(title: new_title)
  end

  test "PUT /categories/:id.json should update a category with the attributes" do
    new_root = Project.find(1).categories.create(title: 'new root')

    new_title = 'Updated title'
    put(
      "/projects/1/knowledgebase/categories/1.json",
      {:category => {:title => new_title, :parent_id => new_root.id}},
      credentials('admin'))
    
    assert_category_updated(title: new_title, parent_id: new_root.id)
    category = KbCategory.find(1)
    assert_equal new_root, category.parent
  end


  def assert_category_updated(params, category_id = 1)
    category = KbCategory.find(category_id)

    params.each do |k, v|
      assert_equal(v, category.send(k))
    end
  end
end
