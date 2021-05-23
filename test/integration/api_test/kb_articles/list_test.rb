require File.expand_path('../../test_helper', __FILE__)

class ListArticlesTest < Redmine::ApiTest::Base
  include KnowledgebaseApiTestHelper

  test "GET /articles.xml should contain metadata" do
    get_articles
    
    assert_select 'articles[type=array][total_count][limit="25"][offset="0"]'
    assert_select 'articles article', 2
  end

  test "GET /articles.xml with offset and limit" do
    get_articles(limit: 1, offset: 1)
    
    assert_select 'articles[type=array][total_count][limit="1"][offset="1"]'
    assert_select 'articles article', 1
  end

  test "GET /articles.xml with attachments" do
    get_articles(include: 'attachments')
    assert_response :success
    assert_equal 'application/xml', @response.content_type

    assert_select 'article id', :text => '1' do
      assert_select '~ attachments attachment', 1
    end

    assert_select 'article id', :text => '2' do
      assert_select '~ attachments'
      assert_select '~ attachments attachment', 0
    end
  end

  test "GET /articles.xml with tags" do
    article = KbArticle.find(1)
    article.tag_list.add("test_tag")
    article.save!

    get_articles(include: 'tags')
    
    assert_select 'article id', :text => '1' do
      assert_select '~ tags tag', 1
      assert_select '~ tags tag', :text => 'test_tag'
    end
  end

  test "GET /articles.xml with comments" do
    article = KbArticle.find(1)
    article.comments.create(author: User.find(1), comments: "very useful")
    article.save!

    get_articles(include: 'comments')
    
    assert_select 'article id', :text => '1' do
      assert_select '~ comments comment', 1
      assert_select '~ comments comment contents', :text => 'very useful'
    end
  end


  def get_articles(params = {})
    url = '/projects/1/knowledgebase/articles.xml'
    url_params = params.map {|k, v| "#{k}=#{v}"}.join('&')
    url += "?#{url_params}" if url_params.present?
    get url, :headers => credentials('admin')
  end
end
