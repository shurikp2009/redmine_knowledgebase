
require File.expand_path('../../test_helper', __FILE__)

class CreateCategoryTest < Redmine::ApiTest::Base
  include KnowledgebaseApiTestHelper

  test "POST /categories.xml should create a category with the attributes" do
    payload = <<-XML
      <?xml version="1.0" encoding="UTF-8" ?>
        <category>
          <project_id>1</project_id>
          <title>title</title>
          <description>description</description>
          <parent_id>1</parent_id>
        </category>
    XML

    assert_creates_category(format: 'xml', payload: payload)
  end

  test "POST /categories.json should create a category with the attributes" do
    payload = <<-JSON
      {
        "category": {
          "project_id": "1",
          "parent_id": "1",
          "title": "title",
          "description": "description"
        }
      }
    JSON

    assert_creates_category(format: 'json', payload: payload)
  end

  test "POST /articles.xml with failure should return errors" do
    assert_no_difference('Issue.count') do
      post(
        '/projects/1/knowledgebase/articles.xml',
        {:category => {:project_id => 1}},
        credentials('admin'))
    end

    assert_select 'errors error', :text => "Title cannot be blank"
  end

  def assert_creates_category(params = {})
    assert_difference('KbCategory.count') do
      post(
        "/projects/1/knowledgebase/categories.#{params[:format]}",
        params[:payload],
        {"CONTENT_TYPE" => "application/#{params[:format]}"}.merge(credentials('admin')))  
    end
  
    category = KbCategory.order('id DESC').first
    assert_equal 1, category.project_id
    assert_equal 1, category.parent_id
    
    assert_equal 'title', category.title
    assert_equal 'description', category.description

    assert_response :created
    assert_equal "application/#{params[:format]}", @response.content_type

    if params[:format] == 'xml'
      assert_select 'category > id', :text => category.id.to_s
    elsif params[:format] == 'json'
      json = JSON(@response.body)
      assert_equal category.id, json["category"]["id"]
    end
  end
end
