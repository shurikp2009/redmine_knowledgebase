require File.expand_path('../../test_helper', __FILE__)

class CreateArticleTest < Redmine::ApiTest::Base
  include KnowledgebaseApiTestHelper

  test "POST /articles.xml should create an article with the attributes" do
    payload = <<-XML
      <?xml version="1.0" encoding="UTF-8" ?>
        <article>
          <project_id>1</project_id>
          <title>title</title>
          <summary>summary</summary>
          <content>content</content>
          <category_id>1</category_id>
        </article>
    XML

    assert_creates_article(format: 'xml', payload: payload)
  end

  test "POST /articles.json should create an article with the attributes" do
    payload = <<-JSON
      {
        "article": {
          "project_id": "1",
          "title": "title",
          "summary": "summary",
          "content": "content",
          "category_id": "1"
        }
      }
    JSON

    assert_creates_article(format: 'json', payload: payload)
  end

  test "POST /articles.xml with failure should return errors" do
    assert_no_difference('Issue.count') do
      post(
        '/projects/1/knowledgebase/articles.xml',
        {:issue => {:project_id => 1}},
        credentials('admin'))
    end

    assert_select 'errors error', :text => "Title cannot be blank"
  end

  def test_create_article_with_uploaded_file
    token = xml_upload('test_create_with_upload', credentials('admin'))
    attachment = Attachment.find_by_token(token)

    # create the issue with the upload's token
    assert_difference 'KbArticle.count' do
      post(
        '/projects/1/knowledgebase/articles.xml',
        
          {:article =>
            {:project_id => 1, :title => 'Uploaded file', :category_id => 1,
             :uploads => [{:token => token, :filename => 'test.txt',
                           :content_type => 'text/plain'}]}},
        credentials('admin'))
      assert_response :created
    end
    
    article = KbArticle.order('id DESC').first
    assert_equal 1, article.attachments.count
    assert_equal attachment, article.attachments.first

    attachment.reload
    assert_equal 'test.txt', attachment.filename
    assert_equal 'text/plain', attachment.content_type
    assert_equal 'test_create_with_upload'.size, attachment.filesize
    assert_equal 1, attachment.author_id

    # get the issue with its attachments
    get "/projects/1/knowledgebase/articles/#{article.id}.xml?include=attachments", {}, credentials('admin')
    assert_response :success
    xml = Hash.from_xml(response.body)
    attachments = xml['article']['attachments']
    assert_kind_of Array, attachments
    assert_equal 1, attachments.size
    url = attachments.first['content_url']
    assert_not_nil url

    # download the attachment
    get url, {}, credentials('admin')
    assert_response :success
    assert_equal 'test_create_with_upload', response.body
  end

  def test_create_article_with_multiple_uploaded_files_as_json
    token1 = json_upload('File content 1', credentials('admin'))
    token2 = json_upload('File content 2', credentials('admin'))

    payload = <<-JSON
      {
        "article": {
          "title": "Article with multiple attachments",
          "category_id": "1",
          "uploads": [
            {"token": "#{token1}", "filename": "test1.txt"},
            {"token": "#{token2}", "filename": "test2.txt"}
          ]
        }
      }
    JSON

    assert_difference 'KbArticle.count' do
      post(
        "/projects/1/knowledgebase/articles.json",
        payload,
        {"CONTENT_TYPE" => 'application/json'}.merge(credentials('admin')))
      assert_response :created
    end

    article = KbArticle.order('id DESC').first
    assert_equal 2, article.attachments.count
  end

  def assert_creates_article(params = {})
    assert_difference('KbArticle.count') do
      post(
        "/projects/1/knowledgebase/articles.#{params[:format]}",
        params[:payload],
        {"CONTENT_TYPE" => "application/#{params[:format]}"}.merge(credentials('admin')))  
    end
  
    article = KbArticle.order('id DESC').first
    assert_equal 1, article.project_id
    
    assert_equal 'summary', article.summary
    assert_equal 'title', article.title
    assert_equal 'content', article.content
    assert_equal 1, article.category_id

    assert_response :created
    assert_equal "application/#{params[:format]}", @response.content_type

    if params[:format] == 'xml'
      assert_select 'article > id', :text => article.id.to_s
    elsif params[:format] == 'json'
      json = JSON(@response.body)
      assert_equal article.id, json["article"]["id"]
    end
  end
end
