require 'yaml'

module Fastlane
  module Actions
    class McForwardChangelogAction < Action
      def self.run(params)
        notes = other_action.wdg_get_current_changelog(yaml_path: '../' + params[:yaml_path])
        the_yaml_path = params[:yaml_path]
        changelog_body = params[:changelog_body]
        yaml_file = File.read(the_yaml_path)
        yaml_changelog = YAML.load(yaml_file)

        changelog_body['notes'] = notes
        yaml_changelog['releases'] = [changelog_body] + yaml_changelog['releases']
        yaml_changelog['upcoming']['notes'] = self.reset_upcoming_notes(notes)

        return yaml_changelog

      end

      def self.reset_upcoming_notes(notes)
        known_issue = notes['已知问题']
        if known_issue == nil
          known_issue = [nil]
        end
        public_changelog = {
            '新增' => [nil],
            '改进' => [nil],
            '修复' => [nil],
            '移除' => [nil],
            '已知问题' => known_issue.dup
        }
        internal_changelog = [nil]
        return {
            "public" => public_changelog,
            'internal' => internal_changelog
        }
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Forward upcoming changelog to released section.'
      end

      def self.details
        'This action will return the forward result changelog string from input yaml, User should manually write it back to changelog file.'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :yaml_path,
                                       env_name: 'MC_YAML_CHANGELOG_PATH',
                                       description: 'you must specify the path to your yaml changelog file',
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :changelog_body,
                                       env_name: 'MC_YAML_CHANGELOG_BODY',
                                       description: 'you must specify the template changelog body',
                                       is_string: false,
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CHANGELOG_HASH', 'The changelog hash']
        ]
      end

      def self.authors
        ['ainopara']
      end

      def self.is_supported?(platform)
        true
      end

    end
  end
end
