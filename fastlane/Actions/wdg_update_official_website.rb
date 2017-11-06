module Fastlane
  module Actions
    module SharedValues
      WDG_UPDATE_OFFICIAL_WEBSITE_CUSTOM_VALUE = :WDG_UPDATE_OFFICIAL_WEBSITE_CUSTOM_VALUE
    end

    class WdgUpdateOfficialWebsiteAction < Action
      def self.run(params)

        version_string = params[:version]
        release_project_name = params[:project]
        official_website_app_id = params[:website_appid]
        official_website_email = params[:website_email]
        official_website_password = params[:website_password]
        official_website_project_name = params[:website_project_name]
        
        cdn_download_url = "https://cdn.wilddog.com/sdk/ios/#{version_string}/#{release_project_name}-#{version_string}.zip"
        build_file_path = "./Deploy/Build/#{release_project_name}-#{version_string}.zip"
        build_file_sha256 = Digest::SHA256.file(build_file_path).hexdigest
        build_file_md5 = Digest::MD5.file(build_file_path).hexdigest
        build_file_sha1 = Digest::SHA1.file(build_file_path).hexdigest

        if ENV['RELEASE_ACTION_OFFICIAL_WEBSITE_DOWNLOAD_URL_UPDATE_ENABLE'] == 'true'
          # puts("wilddog set #{official_website_app_id} wilddog/#{official_website_project_name}/ios/version #{version_string} --email #{official_website_email} --password #{official_website_password}")
          # puts("wilddog set #{official_website_app_id} wilddog/#{official_website_project_name}/ios/cdn #{cdn_download_url} --email #{official_website_email} --password #{official_website_password}")
          # puts("wilddog set #{official_website_app_id} wilddog/#{official_website_project_name}/ios/checksum/md5sum #{build_file_md5} --email #{official_website_email} --password #{official_website_password}")
          # puts("wilddog set #{official_website_app_id} wilddog/#{official_website_project_name}/ios/checksum/sha1sum #{build_file_sha1} --email #{official_website_email} --password #{official_website_password}")
          # puts("wilddog set #{official_website_app_id} wilddog/#{official_website_project_name}/ios/checksum/sha256sum #{build_file_sha256} --email #{official_website_email} --password #{official_website_password}")
          Actions.sh("wilddog set #{official_website_app_id} wilddog/#{official_website_project_name}/ios/version #{version_string} --email #{official_website_email} --password #{official_website_password}")
          Actions.sh("wilddog set #{official_website_app_id} wilddog/#{official_website_project_name}/ios/cdn #{cdn_download_url} --email #{official_website_email} --password #{official_website_password}")
          Actions.sh("wilddog set #{official_website_app_id} wilddog/#{official_website_project_name}/ios/checksum/md5sum #{build_file_md5} --email #{official_website_email} --password #{official_website_password}")
          Actions.sh("wilddog set #{official_website_app_id} wilddog/#{official_website_project_name}/ios/checksum/sha1sum #{build_file_sha1} --email #{official_website_email} --password #{official_website_password}")
          Actions.sh("wilddog set #{official_website_app_id} wilddog/#{official_website_project_name}/ios/checksum/sha256sum #{build_file_sha256} --email #{official_website_email} --password #{official_website_password}")
        end

        if ENV['RELEASE_ACTION_OFFICIAL_WEBSITE_CHANGELOG_UPDATE_ENABLE'] == 'true'
          # puts("wilddog set #{official_website_app_id} changes/iOS/version #{version_string} --email #{official_website_email} --password #{official_website_password}")
          Actions.sh("wilddog set #{official_website_app_id} changes/iOS/version #{version_string} --email #{official_website_email} --password #{official_website_password}")
          # TODO: Finish this.
          # Actions.sh("wilddog set #{official_website_app_id} changes/iOS/change #{} --email #{official_website_email} --password #{official_website_password}")
        end

      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Update wilddog website info using wilddog command line tool."
      end

      def self.details
        "The website info is stored in a sync server."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :project,
                                       description: "The release project name",
                                       optional: false,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :version,
                                       description: "The release version string",
                                       optional: false,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :website_appid,
                                       description: "The sync appid that store the website info",
                                       optional: false,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :website_email,
                                       description: "The email address stored in sync server",
                                       optional: false,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :website_password,
                                       description: "The email password stored in sync server",
                                       optional: false,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :website_project_name,
                                       description: "The website project name stored in sync server",
                                       optional: false,
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :website_changelog,
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
