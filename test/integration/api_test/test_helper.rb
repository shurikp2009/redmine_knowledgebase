require File.expand_path('../../../test_helper', __FILE__)

module KnowledgebaseApiTestHelper
  def self.included(test_class)
    test_class.class_eval do
      fixtures(
        :projects,
        :users,
        :roles,
        :members,
        :member_roles,
        :issues,
        :issue_statuses,
        :issue_relations,
        :versions,
        :trackers,
        :projects_trackers,
        :issue_categories,
        :enabled_modules,
        :enumerations,
        :attachments,
        :workflows,
        :custom_fields,
        :custom_values,
        :custom_fields_projects,
        :custom_fields_trackers,
        :time_entries,
        :journals,
        :journal_details,
        :queries,
        :attachments)
    
      plugin_fixtures :kb_articles, :kb_categories, :enabled_modules, :attachments
    end
  end
end