require 'excon'
require 'securerandom'

module Fastlane
  module Actions

    class UploadSdkToCdnAction < Action
      def self.create_cdn_dir(version)
        url = "http://upload.ops.wilddog.cn/ios/?value=#{version}&type=mkdir"
        UI.message "Make CDN Dir With #{version}"
        response = Excon.post(url)
        if response[:status] == 200
          UI.success("Create CDN Dir #{version} Success ")
        elsif response[:status] != 200
          UI.error("Make CDN Dir responded with #{response[:status]}: #{response[:body]}")
        end
      end

      def self.multipart_form_data(buildpack_file_path)
        body      = ''
        boundary  = SecureRandom.hex(4)
        data      = File.open(buildpack_file_path)
        data.binmode if data.respond_to?(:binmode)
        data.pos = 0 if data.respond_to?(:pos=)
        body << "--#{boundary}" << Excon::CR_NL
        body << %{Content-Disposition: form-data; name="files[]"; filename="#{File.basename(buildpack_file_path)}"} << Excon::CR_NL
        body << 'Content-Type: application/octet-stream' << Excon::CR_NL
        body << Excon::CR_NL
        body << File.read(buildpack_file_path)
        body << Excon::CR_NL
        body << "--#{boundary}" << Excon::CR_NL
        body << %{Content-Disposition: form-data; name="type";} << Excon::CR_NL
        body << Excon::CR_NL
        body << "file" << Excon::CR_NL
        body << Excon::CR_NL
        body << "--#{boundary}" << Excon::CR_NL
        body << %{Content-Disposition: form-data; name="value";} << Excon::CR_NL
        body << Excon::CR_NL
        body << "file upload" << Excon::CR_NL
        body << "--#{boundary}--" << Excon::CR_NL
      
        {
          :headers => { 'Content-Type' => %{multipart/form-data; boundary="#{boundary}"} },
          :body    => body
        }
      end

      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        
        # create version dir
        create_cdn_dir(params[:version])

        # upload sdk to cdn.
        url = "http://upload.ops.wilddog.cn/ios/#{params[:version]}"
        UI.message "upload SDK To CDN. file path: #{params[:file_path]}"

        form_data = multipart_form_data(params[:file_path])

        connectoin = Excon.new(url, :debug_request => true, :debug_response => true)

        response = connectoin.request(
          :method => 'POST',
          :write_timeout => 360,
          :body => form_data[:body],
          :headers => form_data[:headers]
        )

      if response[:status] == 200
        body = JSON.parse(response.body)
        status = body['status']
        if status.eql?("success")
          status_message = "Successfully with #{body[:msg]}."
          UI.success(status_message)
        elsif status.eql?("error")
          msg = body['msg']
          status_message = "Upload sdk failed with #{msg}."
          UI.error(status_message)
      end
        

      elsif response[:status] != 200
        UI.error("Upload SDK responded with #{response[:status]}: #{response[:body]}")
      end
        # sh "shellcommand ./path"

        # Actions.lane_context[SharedValues::UPLOAD_SDK_TO_CDN_CUSTOM_VALUE] = "my_val"
      end

      

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "A short description with <= 80 characters of what this action does"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "You can use this action to do cool things..."
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :version,
                                       env_name: "FL_UPLOAD_SDK_TO_CDN_VERSION", # The name of the environment variable
                                       description: "SDK version", # a short description of this parameter
                                       verify_block: proc do |value|
                                          UI.user_error!("No SDK Version for UploadSdkToCdnAction given, pass using `version: 'version'`") unless (value and not value.empty?)
                                          # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :file_path,
                                       env_name: "FL_UPLOAD_SDK_TO_CDN_FILE_PATH",
                                       description: "SDK File",
                                       is_string: false, # true: verifies the input is a string, false: every kind of value
                                       default_value: false) # the default value if the user didn't provide one
        ]
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["wjp"]
      end

      def self.is_supported?(platform)
        # you can do things like
        # 
        #  true
        # 
        #  platform == :ios
        # 
        #  [:ios, :mac].include?(platform)
        # 

        platform == :ios
      end
    end
  end
end
