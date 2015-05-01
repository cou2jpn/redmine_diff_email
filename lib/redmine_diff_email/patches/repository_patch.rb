require_dependency 'repository'

module RedmineDiffEmail
  module Patches
    module RepositoryPatch

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          safe_attributes 'is_diff_email', 'is_diff_email_attached'
        end
      end

      module InstanceMethods

        def changed_files(path, rev)
          if scm.respond_to?(:changed_files)
            scm.changed_files(path, rev).join.force_encoding("utf-8").scrub
          else
            return ''
          end
        end

      end

    end
  end
end

unless Repository.included_modules.include?(RedmineDiffEmail::Patches::RepositoryPatch)
  Repository.send(:include, RedmineDiffEmail::Patches::RepositoryPatch)
end
