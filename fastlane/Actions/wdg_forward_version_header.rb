module Fastlane
  module Actions
    class WdgForwardVersionHeaderAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        
        project_name = params[:project_name]
        version_string = params[:version_string]
        header_path = "#{project_name}/#{project_name}Version.h"
        header_template_path = "#{project_name}/#{project_name}Version.h.mustache"

        Dir.chdir '.' do
          open(header_path, 'w') do |version_header_content|
            template = open(header_template_path, 'r')
            version_header_content << Mustache.render(
              template.read,
              version: version_string
            )
          end
        end

        UI.success('Version header is up to date now. 🌝')

      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Update version header for the project."
      end

      def self.details
        "The header file must exist."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :version_string,
                                       description: "The release version string",
                                       optional: false,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :project_name,
                                       description: "The Xcode project name",
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
