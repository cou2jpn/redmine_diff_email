# Set up autoload of patches
Rails.configuration.to_prepare do
  require_dependency 'redmine_diff_email/patches/changeset_patch'
  require_dependency 'redmine_diff_email/patches/mailer_patch'
  require_dependency 'redmine_diff_email/patches/repository_patch'

  require_dependency 'redmine_diff_email/patches/git_adapter_patch'
  require_dependency 'redmine_diff_email/patches/mercurial_adapter_patch'
  require_dependency 'redmine_diff_email/patches/subversion_adapter_patch'
end

require_dependency 'redmine_diff_email/hooks/repository_form_hook'
