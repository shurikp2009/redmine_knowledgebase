class CategoriesController < ApplicationController
  unloadable

  menu_item :articles
  helper :knowledgebase
  include KnowledgebaseHelper
  helper :watchers
  include WatchersHelper

  before_filter :find_project_by_project_id, :authorize
  before_filter :get_category, :only => [:show, :edit, :update, :destroy, :index]
  accept_rss_auth :show
  accept_api_auth :index, :show, :create, :update, :destroy

  rescue_from ActiveRecord::RecordNotFound, :with => :force_404

  def index

    @articles = @project.articles.order("#{sort_column} #{sort_direction}")

    prepare

    respond_to do |format|
      format.html { render :template => 'categories/index', :layout => !request.xhr? }
      format.api {
        @offset, @limit = api_offset_and_limit
        @categories = @project.categories.offset(@offset).limit(@limit)
      }
    end

  end

  def show

    @articles = @category.articles.order("#{sort_column} #{sort_direction}")

    prepare

    @tags = @articles.tag_counts.sort { |a, b| a.name.downcase <=> b.name.downcase }

    respond_to do |format|
      format.html { render :template => 'categories/show', :layout => !request.xhr? }
      format.atom { render_feed(@articles, :title => "#{l(:knowledgebase_title)}: #{l(:label_category)}: #{@category.title}") }

      format.api
    end

  end

  def new
    @category = KbCategory.new
    @parent_id = params[:parent_id]
    @categories=@project.categories.all
  end

  def create
    @category = KbCategory.new(params[:category])
    @category.project_id=@project.id
    
    if @category.save
      # Test if the new category is a root category, and if more categories exist.
      # We check for a value > 1 because if this is the first entry, the category
      # count would be 1 (since the create operation already succeeded)
      if !params[:root_category] and @project.categories.count > 1
        parent_id = !api_request? ? params[:parent_id] : params[:category][:parent_id]
        @category.move_to_child_of(KbCategory.find(parent_id))
      end

      respond_to do |format|
        format.html {
          flash[:notice] = l(:label_category_created, :title => @category.title)
          redirect_to({ :action => 'show', :id => @category.id, :project_id => @project })
        }

        format.api  { render :action => 'show', :status => :created, :location => category_url(@category, project_id: @category.project_id) }
      end
    else
      respond_to do |format|
        format.html {
          render(:action => 'new')
        }
        format.api  { render_validation_errors(@category) }
      end
    end
  end

  def edit
    @parent_id = @category.parent_id
    @categories=@project.categories.all
  end

  def destroy
    @categories = @project.categories.all

    # Do not allow deletion of categories with existing subcategories
    @subcategories = @project.categories.where(:parent_id => @category.id)

    if @subcategories.size != 0
      respond_to do |format|
        format.html { 
          @articles = @category.articles.all
          flash[:error] = l(:label_category_has_subcategory_cannot_delete)
          render(:action => 'show')
        }

        format.api  { render_api_errors(l(:label_category_has_subcategory_cannot_delete)) }
      end
    elsif @category.articles.size != 0
      respond_to do |format|
        format.html { 
          @articles = @category.articles.all
          flash[:error] = l(:label_category_not_empty_cannot_delete)
          render(:action => 'show')
        }
  
        format.api  { render_api_errors(l(:label_category_not_empty_cannot_delete)) }
      end
    else
      @category.destroy

      respond_to do |format|
        format.html { 
          flash[:notice] = l(:label_category_deleted)
          redirect_to({ :controller => :articles, :action => 'index', :project_id => @project})
        }
  
        format.api  { render_api_ok }
      end
  
    end
  end

  def update
    if params[:root_category] == "yes"
      @category.parent_id = nil
    else
      unless api_request?
        @category.move_to_child_of(KbCategory.find(params[:parent_id]))
      end
    end

    if @category.update_attributes(params[:category])
      flash[:notice] = l(:label_category_updated)
      redirect_to({ :action => 'show', :id => @category.id, :project_id => @project })
    else
      render :action => 'edit'
    end
  end

#######
private
#######

  def get_category
    if params[:id] != nil
      @category = @project.categories.find(params[:id])
    end
  end

  def force_404
    render_404
  end

  def prepare

    if params[:tag]
      @tag = params[:tag]
      @tag_array = *@tag.split(',')
      @tag_hash = Hash[ @tag_array.map{ |tag| [tag.downcase, 1] } ]
      @articles = @articles.tagged_with(@tag)
    end

    @tags = @articles.tag_counts.sort { |a, b| a.name.downcase <=> b.name.downcase }
    @tags_hash = Hash[ @articles.tag_counts.map{ |tag| [tag.name.downcase, 1] } ]

    # Pagination of article lists
    @limit = redmine_knowledgebase_settings_value( :articles_per_list_page).to_i
    @article_count = @articles.count
    @article_pages = Redmine::Pagination::Paginator.new @article_count, @limit, params['page']
    @offset ||= @article_pages.offset
    @articles = @articles.offset(@offset).limit(@limit)

    @categories = @project.categories.where(:parent_id => nil)
  end

end
