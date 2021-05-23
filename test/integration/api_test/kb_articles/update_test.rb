require File.expand_path('../../test_helper', __FILE__)

class UpdateArticleTest < Redmine::ApiTest::Base
  include KnowledgebaseApiTestHelper

  test "PUT /articles.xml should update an article with the attributes" do
    assert_updates(title: 'New title', category_id: 2, content: 'New content', summary: 'New summary')
  end

  test "PUT /articles.json should update an article with the attributes" do
    assert_updates(title: 'New title', format: 'json')
  end

  test "PUT /articles.json should attach an uploaded file to an article" do
    token = xml_upload('test_upload_with_upload', credentials('admin'))
    attachment = Attachment.find_by_token(token)

    put_article(
      :params =>
          {:article =>
            {
              :uploads =>
                [{:token => token, :filename => 'test.txt',
                  :content_type => 'text/plain'}]}}
    )
    assert_response :no_content
    assert_equal '', @response.body

    article = KbArticle.find(1)
    assert_include attachment, article.attachments
  end

  def assert_article_updated(params, article_id = 1)
    article = KbArticle.find(article_id)

    params.each do |k, v|
      assert_equal(v, article.send(k))
    end
  end

  def assert_updates(attrs)
    options = {
      format: attrs.delete(:format), 
      id: attrs.delete(:id),
      params: {:article => attrs}
    }.merge({id: 1, format: 'xml'})

    put_article options
    assert_article_updated(attrs, options[:id])
  end

  def put_article(options = {})
    options = {id: 1, format: 'xml'}.merge(options)
    put(
      "/projects/1/knowledgebase/articles/#{options[:id]}.#{options[:format]}",
      :params => options[:params],
      :headers => credentials('admin'))
  end
end