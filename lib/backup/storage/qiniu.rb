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

      def remove!(pkg)
        remote_path = remote_path_for(pkg)
        establish_connection!
        transferred_files_for(pkg) do |local_file, remote_file|
          Logger.message "#{storage_name} started removing " +
              "'#{ local_file }' from bucket '#{ bucket }'."
          key = File.join(remote_path, remote_file)
          unless ::Qiniu::RS.delete(bucket, key)
            raise "delete '#{key}' failed"
          end
        end
      end

      def transfer!
        establish_connection!
        remote_path = remote_path_for(@package)
        files_to_transfer_for(@package) do |local_file, remote_file|
          Logger.message "#{storage_name} started transferring " +
              "'#{ local_file }'."
          upload_token = ::Qiniu::RS.generate_upload_token :scope => bucket
          key = File.join(remote_path, remote_file)
          res = ::Qiniu::RS.upload_file :uptoken            => upload_token,
                 :file               => File.join(local_path, local_file),
                 :key                => key,
                 :bucket             => bucket,
                 :enable_crc32_check => true
          raise "upload '#{local_file}' failed" if res == false
          Logger.message "file uploaded to bucket:#{bucket}, key:#{key}"
        end
      end

      private
      def establish_connection!
        ::Qiniu::RS.establish_connection! :access_key => access_key,
                                          :secret_key => access_secret
      end
    end
  end
end
