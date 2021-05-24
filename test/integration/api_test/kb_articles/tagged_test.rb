require File.expand_path('../../test_helper', __FILE__)

class TaggedArticlesTest < Redmine::ApiTest::Base
  include KnowledgebaseApiTestHelper

  test "GET /articles/tagged.xml" do
    article = KbArticle.find(1)
    article.tag_list.add("test_tag")
    article.save!

    get '/projects/1/knowledgebase/articles/tagged.xml', 
      { id: "test_tag" },
      credentials('admin')
    
    assert_select 'articles article', 1
    assert_select 'article id', :text => '1'
  end
end
