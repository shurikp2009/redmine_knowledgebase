require File.expand_path('../../test_helper', __FILE__)

class DestroyArticleTest < Redmine::ApiTest::Base
  include KnowledgebaseApiTestHelper

  test "DELETE /articles/:id.json" do
    assert_difference('KbArticle.count', -1) do
      delete '/projects/1/knowledgebase/articles/1.xml', {}, credentials('admin')

      assert_response :ok
      assert_equal '', response.body
    end
    assert_nil KbArticle.find_by_id(1)
  end
end
