require File.expand_path('../../test_helper', __FILE__)

class ShowArticleTest < Redmine::ApiTest::Base
  include KnowledgebaseApiTestHelper

  test "GET /articles/:id.xml should return article" do
    get '/projects/1/knowledgebase/articles/1.xml', :headers => credentials('admin')
    assert_select 'article id', text: '1'
    assert_select 'article title', text: 'MyString'
    
    assert_select 'article version', text: '0'
  end

  test "GET /articles/:id.xml should show comments" do
    create_comment("awesome!")

    get '/projects/1/knowledgebase/articles/1.xml?include=comments', :headers => credentials('admin')
    
    assert_select 'article comments comment contents', text: 'awesome!'
  end

  def article
    KbArticle.find(1)
  end

  def create_comment(contents)
    article.comments.create(author: User.find(1), comments: contents)
  end
end
