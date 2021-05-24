require File.expand_path('../../test_helper', __FILE__)

class ArticleVersionTest < Redmine::ApiTest::Base
  include KnowledgebaseApiTestHelper

  test "GET /articles/:id/version.xml should return article version" do
    article.update_attributes!(content: "second version")

    get "/projects/1/knowledgebase/articles/#{article.id}/version.xml", {version: 1}, credentials('admin')

    assert_select 'article_version version', text: '1'
    assert_select 'article_version content', text: 'first version'
  end

  def article
    @article ||= KbArticle.create(author_id: 1, content: 'first version', title: 'title', summary: 'summary', category_id: 1, project_id: 1)
  end
end
