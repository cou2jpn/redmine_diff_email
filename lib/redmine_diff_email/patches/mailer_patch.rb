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
          # If the committer is a user of Redmine, and passes @author to mailer.rb.
          @author = changeset.author if changeset.author.try(:mail)
          @author_s = changeset.author.to_s

          redmine_headers 'Project'   => @project.identifier,
                          'Committer' => @author.try(:login) || @author_s,
                          'Revision'  => changeset.revision

          to = @project.users.select {|u| u.mail_notification != 'none' && u.allowed_to?(:view_changesets, @project)}

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
               :subject => subject
        end

      end

    end
  end
end

unless Mailer.included_modules.include?(RedmineDiffEmail::Patches::MailerPatch)
  Mailer.send(:include, RedmineDiffEmail::Patches::MailerPatch)
end
