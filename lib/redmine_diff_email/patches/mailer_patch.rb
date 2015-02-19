require_dependency 'mailer'

module RedmineDiffEmail
  module Patches
    module MailerPatch

      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
        end
      end

      module InstanceMethods

        def changeset_added(changeset, is_attached)

          @project = changeset.repository.project

          author = changeset.user unless changeset.user.nil?
          @author_s = author.nil? ? changeset.author.to_s : author.login

          redmine_headers 'Project'   => @project.identifier,
                          'Committer' => @author_s,
                          'Revision'  => changeset.revision

          to = @project.notified_users.select {
            |u| u.allowed_to?(:view_changesets, @project)
          }.collect {
            |u| u.mail
          }
          to.delete(author.mail) unless author.nil?
          cc = author.mail unless author.nil?

          Rails.logger.info "mailing changeset to " + to.to_sentence

          subject = "[#{@project.name}: #{l(:label_repository)}] #{changeset.format_identifier} #{changeset.short_comments}"

          @is_attached = is_attached
          @changeset = changeset

          @changed_files = @changeset.repository.changed_files("", @changeset.revision)
          diff = @changeset.repository.diff("", @changeset.revision, nil)

          @changeset_url = url_for(:controller => 'repositories', :action => 'revision', :rev => @changeset.revision, :id=> @project, :repository_id => changeset.repository)

          set_language_if_valid @changeset.user.language unless changeset.user.nil?

          if !diff.nil? && @is_attached
            attachments["changeset_r#{changeset.revision}.diff"] = diff.join
          end

          mail :to => to,
               :cc => cc,
               :subject => subject
        end

      end

    end
  end
end

unless Mailer.included_modules.include?(RedmineDiffEmail::Patches::MailerPatch)
  Mailer.send(:include, RedmineDiffEmail::Patches::MailerPatch)
end
