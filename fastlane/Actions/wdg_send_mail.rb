require 'mail'

module Fastlane
  module Actions
    module SharedValues
      WDG_SEND_MAIL_CUSTOM_VALUE = :WDG_SEND_MAIL_CUSTOM_VALUE
    end

    class WdgSendMailAction < Action
      def self.run(params)

        version_string = params[:version]
        release_project_name = ENV['WDG_PROJECT_NAME']
        public_changelog = other_action.wdg_get_current_changelog(yaml_path: '../' + ENV['CHANGELOG_PATH'])['public']

        Mail.defaults do
          delivery_method :smtp, {
            :address              => 'smtp.partner.outlook.cn',
            :port                 => 587,
            :domain               => 'wilddog.com',
            :user_name            => ENV['EMAIL_USERNAME'],
            :password             => ENV['EMAIL_PASSWORD'],
            :authentication       => :login,
            :enable_starttls_auto => true
          }
        end

        template_changelog = {}
        template_changelog['add'] = public_changelog['新增'].map { |entity| { 'content' => entity } } unless public_changelog['新增'].nil?
        template_changelog['improve'] = public_changelog['改进'].map { |entity| { 'content' => entity } } unless public_changelog['改进'].nil?
        template_changelog['repair'] = public_changelog['修复'].map { |entity| { 'content' => entity } } unless public_changelog['修复'].nil?
        template_changelog['remove'] = public_changelog['移除'].map { |entity| { 'content' => entity } } unless public_changelog['移除'].nil?
        notification_mail_template_path = "fastlane/notification.html.mustache"
        template = open('./' + notification_mail_template_path, 'r')
        notification_mail_content = Mustache.render(
          template.read,
          release_project_name: release_project_name,
          version_string: version_string,
          changelog: template_changelog
        )

        user_group = ENV['EMAIL_NOTIFICATION_ADDRESS'].split(' ')
        UI.message("Sending email to #{user_group}.")
        Mail.deliver do
          from    ENV['EMAIL_USERNAME']
          to      user_group
          subject "#{release_project_name} iOS #{version_string} 上线通知"
          html_part do
            content_type 'text/html; charset=UTF-8'
            body         notification_mail_content
          end
        end

      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Send the changelog to specified email address."
      end

      def self.details
        "List the email receiver in env file, separated by space character."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :version,
                                       description: "The release version string",
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
