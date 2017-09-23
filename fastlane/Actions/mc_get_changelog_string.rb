require 'yaml'

module Fastlane
  module Actions
    class McGetChangelogStringAction < Action
      def self.run(params)
        public_changelog = other_action.wdg_get_current_changelog(yaml_path: '../' + params[:yaml_path])['public']

        changelog_string = ''
        ['新增', '改进', '修复', '移除', '已知问题'].each { |type|
          if public_changelog[type] != nil and public_changelog[type] != [nil]
            public_changelog[type].each { |entity|
              changelog_string += "[#{type}] #{entity}\n\n"
            }
          end
        }

        return changelog_string
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Translate changelog yaml to string'
      end

      def self.details
        'This action will return the changelog string from input yaml.'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :yaml_path,
                                       env_name: 'MC_YAML_CHANGELOG_PATH',
                                       description: 'you must specify the path to your yaml changelog file',
                                       is_string: true,
                                       optional: false)
        ]
      end

      def self.output
        [
          ['CHANGELOG_STRING', 'The changelog string']
        ]
      end

      def self.authors
        ['ainopara']
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end
    end
  end
end
