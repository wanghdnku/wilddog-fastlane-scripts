require 'excon'

module Fastlane
  module Actions
    module SharedValues
      CREATE_MERGE_REQUEST_HTML_URL = :CREATE_MERGE_REQUEST_HTML_URL
    end

    class CreateMergeRequestAction < Action
      def self.run(params)
        UI.message("Creating new merge request from '#{params[:source_branch]}' of '#{params[:source_project]}' to branch '#{params[:target_branch]}' of '#{params[:target_project]}'")

        url = "#{params[:api_url]}/api/v3/projects/#{params[:source_project]}/merge_requests"
        headers = { 'User-Agent' => 'fastlane-create_merge_request' }
        headers['PRIVATE-TOKEN'] = params[:api_token] if params[:api_token]

        data = {
          'id' => params[:source_project],
          'target_project_id' => params[:target_project],
          'source_branch' => params[:source_branch],
          'target_branch' => params[:target_branch],
          'title' => params[:title]
        }

        data['description'] = params[:description] if params[:description]
        data['assignee_id'] = params[:assignee] if params[:assignee]

        response = Excon.post(url, headers: headers, query: data)

        if response[:status] == 201
          body = JSON.parse(response.body)
          number = body['iid']
          issue_id = body['id']
          success_message = "Successfully created merge request ##{number} with **id** #{issue_id}."
          unless params[:path_with_namespace].nil?
            html_url = "#{params[:api_url]}/#{params[:path_with_namespace]}/merge_requests/#{number}"
            success_message += " You can see it at '#{html_url}'"
          end
          UI.success(success_message)

          Actions.lane_context[SharedValues::CREATE_PULL_REQUEST_HTML_URL] = html_url
          return issue_id
        elsif response[:status] != 200
          UI.error("GitLab responded with #{response[:status]}: #{response[:body]}")
          return 0
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'This will create a new merge request on Gitlab'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: 'GITLAB_MERGE_REQUEST_API_TOKEN',
                                       description: 'Personal API Token for GitLab - generate one at https://gitlab.com/profile/account',
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :source_project,
                                       env_name: 'GITLAB_MERGE_REQUEST_SOURCE_PROJECT_ID',
                                       description: 'The id of the repository you want to submit the merge request from',
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :target_project,
                                       env_name: 'GITLAB_MERGE_REQUEST_TARGET_PROJECT_ID',
                                       description: 'The id of the repository you want to submit the merge request to',
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :title,
                                       env_name: 'GITLAB_MERGE_REQUEST_TITLE',
                                       description: 'The title of the merge request',
                                       is_string: true,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :description,
                                       env_name: 'GITLAB_MERGE_REQUEST_DESCRIPTION',
                                       description: 'The contents of the merge request',
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :source_branch,
                                       env_name: 'GITLAB_MERGE_REQUEST_SOURCE_BRANCH',
                                       description: 'The name of the branch where your changes are implemented (defaults to the current branch name)',
                                       is_string: true,
                                       default_value: Actions.git_branch,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :target_branch,
                                       env_name: 'GITLAB_MERGE_REQUEST_TARGET_BRANCH',
                                       description: 'The name of the branch you want your changes merged into (defaults to `master`)',
                                       is_string: true,
                                       default_value: 'master',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :assignee,
                                       env_name: 'GITLAB_MERGE_REQUEST_ASSIGNEE',
                                       description: 'The id of the user this merge request assigned to',
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :path_with_namespace,
                                       env_name: 'GITLAB_MERGE_REQUEST_PATH_WITH_NAMESPACE',
                                       description: 'Specific this will allow this action show url address of created merge request when success',
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :api_url,
                                       env_name: 'GITLAB_MERGE_REQUEST_API_URL',
                                       description: 'The URL of GitLab API - used when the Enterprise (default to `https://gitlab.com`)',
                                       is_string: true,
                                       default_value: 'https://gitlab.com',
                                       optional: true)
        ]
      end

      def self.author
        ['ainopara']
      end

      def self.is_supported?(platform)
        return true
      end

      def self.example_code
        [
          'create_merge_request(
            api_token: ENV["GITLAB_TOKEN"],
            source_project: "1",
            target_project: "1",
            title: "Amazing new feature",
            description: "Please pull this in!",            # optional
            source_branch: "my-feature",                    # optional, defaults to current branch name
            target_branch: "master",                        # optional, defaults to "master"
            assignee: "1",                                  # optional
            path_with_namespace: "group-name/project-name", # optional
            api_url: "http://your.domain"                    # optional, for Gitlab Enterprise, defaults to "https://gitlab.com"
          )'
        ]
      end

      def self.output
        [
          ['GITLAB_ISSUE_ID', 'GitLab issue ID']
        ]
      end

      def self.category
        :source_control
      end
    end
  end
end
