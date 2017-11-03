module Fastlane
  module Actions
    class WdgUpdatePodspecAction < Action
      def self.run(params)
        project_name = params[:project_name]
        version_string = params[:version_string]
        update_local = params[:update_local]

        podspec_path = "#{project_name}.podspec"
        build_file_path = "Deploy/Build/#{project_name}-#{version_string}.zip"
        build_file_sha256 = Digest::SHA256.file('./' + build_file_path).hexdigest

        Dir.chdir './Deploy' do
          open("#{project_name}.podspec", 'w') do |podspec|
            template = open("#{release_project_name}.podspec.mustache", 'r')
            podspec << Mustache.render(
              template.read,
              version: version_string,
              sha256: build_file_sha256
            )
          end
        end
        UI.success('Public podspec has been updated. 🌝')

        if update_local do
          Dir.chdir '..' do
            open("#{project_name}.podspec", 'w') do |podspec|
              template = open("#{release_project_name}.podspec.mustache", 'r')
              podspec << Mustache.render(
                template.read,
                version: version_string
              )
            end
          end
          UI.success('Local podspec has been updated. 🌝')
        end

      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Update podspec file for CocoaPods"
      end

      def self.details
        "This action can update public podspec and local podspec"
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
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :update_local,
                                       description: "Also update local podspec for source code integration",
                                       is_string: false,
                                       default_value: false)
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
