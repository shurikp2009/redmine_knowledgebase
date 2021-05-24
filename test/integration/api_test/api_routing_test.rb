
require File.expand_path('../../../test_helper', __FILE__)

class Redmine::ApiTest::ApiRoutingTest < Redmine::ApiTest::Routing

  def test_articles
    should_route 'GET /projects/1/knowledgebase/articles' => 'articles#index', :project_id => '1'
  end

  def test_create_article
    should_route 'POST /projects/1/knowledgebase/articles' => 'articles#create', :project_id => '1'
  end
end
