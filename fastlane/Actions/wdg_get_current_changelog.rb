require 'yaml'

module Fastlane
  module Actions
    class WdgGetCurrentChangelogAction < Action
      def self.run(params)
        the_yaml_path = params[:yaml_path]
        yaml_file = File.read(the_yaml_path)
        yaml_changelog = YAML.load(yaml_file)
        public_changelog = yaml_changelog['upcoming']['notes']['public']
        internal_changelog = yaml_changelog['upcoming']['notes']['internal']

        return {
            'public' => self.cleaning_public_changelog(public_changelog),
            'internal' => internal_changelog || []
        }

      end

      def self.cleaning_public_changelog(notes)
        new_release_notes = {}
        if notes.nil?
          return new_release_notes
        end
        ['新增', '改进', '修复', '移除', '已知问题'].each { |type|
          if notes[type] != nil and notes[type] != [nil]
            new_release_notes[type] = notes[type]
          end
        }
        return new_release_notes
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "A short description with <= 80 characters of what this action does"
      end

      def self.details
        "You can use this action to do cool things..."
      end

      def self.available_options
        [
            FastlaneCore::ConfigItem.new(key: :yaml_path,
                                         env_name: 'WDG_YAML_CHANGELOG_PATH',
                                         description: 'you must specify the path to your yaml changelog file',
                                         is_string: true,
                                         optional: false)
        ]
      end

      def self.output
        [
          ['WDG_GET_CURRENT_CHANGELOG_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If you method provides a return value, you can describe here what it does
      end

      def self.authors
        ["ainopara"]
      end

      def self.is_supported?(platform)
        true
      end

    end
  end
end
