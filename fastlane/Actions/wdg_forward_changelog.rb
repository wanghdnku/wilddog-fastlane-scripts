require 'yaml'

module Fastlane
  module Actions
    class WdgForwardChangelogAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        # sh "shellcommand ./path"

        new_release_changelog = {
          'version' => params[:version_string],
          'type' => 'Release',
          'date' => Time.now.strftime('%Y-%m-%d')
        }

        notes = other_action.wdg_get_current_changelog(yaml_path: '../' + params[:changelog_path])
        yaml_file = File.read(params[:changelog_path])
        yaml_changelog = YAML.load(yaml_file)

        new_release_changelog['notes'] = notes
        yaml_changelog['releases'] = [new_release_changelog] + yaml_changelog['releases']
        yaml_changelog['upcoming']['notes'] = self.reset_upcoming_notes(notes)

        Dir.chdir '.' do
          File.write(params[:changelog_path], yaml_changelog.to_yaml)
        end

        UI.success('Changelog is up to date now. 🌝')
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
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "This action will forward the CHANGELOG.yaml."
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :version_string,
                                       description: "The release version string",
                                       optional: false,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :changelog_path,
                                       description: "The YAML changelog path",
                                       optional: false,
                                       is_string: true)
        ]
      end

      def self.authors
        ["Hayden"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end

    end
  end
end
