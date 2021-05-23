
require File.expand_path('../test_helper', __FILE__)

class DestroyCategoryTest < Redmine::ApiTest::Base
  include KnowledgebaseApiTestHelper

  test "DELETE /categories/:id.json should delete empty category" do
    assert_difference('KbCategory.count', -1) do
      destroy_category 3
      assert_response :no_content
      assert_equal '', response.body
    end
    assert_nil KbCategory.find_by_id(3)
  end

  test "DELETE /categories/:id.json should not delete category with articles" do
    assert_difference('KbCategory.count', 0) do
      destroy_category 1
      assert_select 'errors error', :text => "Category can not be deleted because it contains articles."
    end
    assert_not_nil KbCategory.find_by_id(3)
  end

  def destroy_category(id)
    delete "/projects/1/knowledgebase/categories/#{id}.xml", :headers => credentials('admin')
  end
end
