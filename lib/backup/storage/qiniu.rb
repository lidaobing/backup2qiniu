require 'backup/logger'
require 'qiniu/rs'

module Backup
  module Storage
    class Qiniu < Base

      attr_accessor :access_key, :access_secret
      attr_accessor :bucket

      def initialize(model, storage_id = nil, &block)
        super(model, storage_id)

        @bucket ||= 'backups'

        instance_eval(&block) if block_given?
      end

      def path
        ''
      end

      def transfer!
        ::Qiniu::RS.establish_connection! :access_key => access_key,
                                          :secret_key => access_secret

        remote_path = remote_path_for(@package)
        files_to_transfer_for(@package) do |local_file, remote_file|
          Logger.message "#{storage_name} started transferring " +
              "'#{ local_file }'."
          remote_upload_url = ::Qiniu::RS.put_auth
          raise "auth failed" if ! remote_upload_url
          key = File.join(remote_path, remote_file)
          ::Qiniu::RS.upload :url                => remote_upload_url,
                 :file               => File.join(local_path, local_file),
                 :key                => key,
                 :bucket             => bucket,
                 :enable_crc32_check => true
          Logger.message "file uploaded to bucket:#{bucket}, key:#{key}"
        end
      end
    end
  end
end
