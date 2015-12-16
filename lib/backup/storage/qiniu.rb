require 'backup/logger'
require 'qiniu/rs'
require 'rest_client'
require 'base64'

module Backup
  module Storage
    class Qiniu < Base
      attr_accessor :access_key, :access_secret
      attr_accessor :upload_token
      attr_accessor :bucket
      attr_accessor :path

      def initialize(model, storage_id = nil)
        super(model, storage_id)

        @bucket ||= 'backups'
        @path ||= ''
      end

      def remove!(pkg)
        remote_path = remote_path_for(pkg)
        establish_connection!
        package.filenames.each do |remote_file|
          Logger.info "#{storage_name} started removing " +
              "'#{ remote_file }' from bucket '#{ bucket }'."
          key = File.join(remote_path, remote_file)
          unless ::Qiniu::RS.delete(bucket, key)
            raise "delete '#{key}' failed"
          end
        end
      end

      def transfer!
        if access_key and access_secret
          transfer_by_secret!
        else
          transfer_by_upload_token!
        end
      end

      private

      def transfer_by_upload_token!
        raise "upload_token is not set" if upload_token.nil?
        package.filenames.each do |local_file|
          remote_file = local_file
          Logger.info "[transfer_by_upload_token] #{storage_name} started transferring " +
              "'#{ local_file }'."
          key = File.join(remote_path, remote_file)
          upload_file(File.join(Config.tmp_path, local_file), key)
          Logger.info "file uploaded to bucket:#{bucket}, key:#{key}"
        end
      end

      def upload_file(local_file, key)
        RestClient.post 'http://up.qbox.me/upload',
          :auth => upload_token,
          :action => action(bucket, key),
          :file => File.open(local_file)
      end

      def transfer_by_secret!
        establish_connection!
        package.filenames.each do |local_file|
          remote_file = local_file
          Logger.info "[transfer_by_secret] #{storage_name} started transferring " +
              "'#{ local_file }'."
          upload_token = ::Qiniu::RS.generate_upload_token :scope => bucket
          key = File.join(remote_path, remote_file)
          res = ::Qiniu::RS.upload_file :uptoken            => upload_token,
                 :file               => File.join(Config.tmp_path, local_file),
                 :key                => key,
                 :bucket             => bucket,
                 :enable_crc32_check => true
          raise "upload '#{local_file}' failed" if res == false
          Logger.info "file uploaded to bucket:#{bucket}, key:#{key}"
        end
      end

      def establish_connection!
        raise "access_key is nil" if access_key.nil?
        raise "access_secret is nil" if access_secret.nil?
        ::Qiniu::RS.establish_connection! :access_key => access_key,
                                          :secret_key => access_secret
      end

      def action(bucket, key)
        "/rs-put/#{Base64.urlsafe_encode64("#{bucket}:#{key}")}"
      end
    end
  end
end
