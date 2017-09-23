require 'excon'

module Fastlane
  module Actions
    module SharedValues
      ACCEPT_MERGE_REQUEST_CUSTOM_VALUE = :ACCEPT_MERGE_REQUEST_CUSTOM_VALUE
    end

    class AcceptMergeRequestAction < Action
      def self.run(params)
        # noinspection RubocopInspection
        UI.message("Accepting merge request with issue '#{params[:issue_id]}' in project '#{params[:project_id]}'.")

        url = "#{params[:api_url]}/api/v3/projects/#{params[:project_id]}/merge_requests/#{params[:issue_id]}/merge"
        headers = { 'User-Agent' => 'fastlane-accept_merge_request' }
        headers['PRIVATE-TOKEN'] = params[:api_token] if params[:api_token]

        data = {
          'id' => params[:project_id],
          'merge_request_id' => params[:issue_id]
        }

        response = Excon.put(url, headers: headers, query: data)

        if response[:status] == 200
          UI.success("Successfully accept merge request #{params[:issue_id]}.")
        elsif response[:status] != 200
          UI.user_error!("GitLab responded with #{response[:status]}: #{response[:body]}")
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'This will accept a merge request on Gitlab'
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: 'GITLAB_MERGE_REQUEST_API_TOKEN',
                                       description: 'Personal API Token for GitLab - generate one at https://gitlab.com/profile/account',
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :project_id,
                                       env_name: 'GITLAB_MERGE_REQUEST_TARGET_PROJECT_ID',
                                       description: 'The id of the repository you want to accept the merge request in',
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :issue_id,
                                       env_name: 'GITLAB_MERGE_REQUEST_TARGET_ISSUE_ID',
                                       description: 'The id of the merge request you want to accept',
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :api_url,
                                       env_name: 'GITLAB_MERGE_REQUEST_API_URL',
                                       description: 'The URL of GitLab API - used when the Enterprise (default to `https://gitlab.com`)',
                                       is_string: true,
                                       default_value: 'https://gitlab.com',
                                       optional: true)
        ]
      end

      def self.authors
        ['ainopara']
      end

      def self.is_supported?(platform)
        true
      end

      def self.category
        :source_control
      end
    end
  end
end
