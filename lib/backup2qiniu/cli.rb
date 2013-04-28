require 'thor'
require 'qiniu-rs'

module Backup2qiniu
  class CLI < Thor
    desc 'gen_token', 'Generate a Upload Token for backup'
    def gen_token
      puts 'input your keys (you can find them on https://dev.qiniutek.com/account/keys)'
      token = get_param("Access Key")
      secret = get_param("Secret Key")
      Qiniu::RS.establish_connection! :access_key => token, :secret_key => secret
      buckets = Qiniu::RS.buckets
      unless buckets
        puts 'Can not verify your key, wrong key?'
        exit 1
      end
      bucket = get_bucket_name(buckets)
      days = get_param("Token Valid Days (365)")
      if days == ''
        days = 365
      else
        days = days.to_i
      end

      print_params access_key: token, secret_key: secret, bucket: bucket, valid_days: days

      print_token Qiniu::RS.generate_upload_token(:expires_in => 3600*24*days, :scope => bucket), bucket
    end

    private
    def print_token(token, bucket)
      puts %Q{
  # Copy following lines to your config file
  store_with Qiniu do |q|
    q.upload_token = #{token.inspect}
    q.bucket = #{bucket.inspect}
    # q.path = 'BACKUP_DIR1'
  end
      }
    end

    def get_bucket_name(buckets)
      puts "Your buckets: #{buckets.join(", ")}"
      bucket = get_param("Select Bucket")
      return bucket if buckets.include? bucket
      puts 'ERROR: invalid bucket name'
      puts
      get_bucket_name(buckets)
    end

    def print_params(h)
      puts
      puts 'Params'
      h.each do |k, v|
        puts "#{k}: #{v}"
      end
    end

    def get_param(hint)
      STDOUT.write "#{hint}: "
      STDIN.gets.chomp
    end
  end
end
