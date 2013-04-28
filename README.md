# Backup2qiniu

备份你的数据、文件到 [qiniutek.com](http://www.qiniutek.com/)

## 使用方法

* 运行 gem install backup2qiniu
* 运行 backup generate:config
* 运行 backup generate:model --trigger=mysql_backup_qiniu
* 访问 https://dev.qiniutek.com/account/keys, 找到你的 "Access Key" 和 "Access Secret"
* 修改 ~/Backup/models/mysql_backup_qiniu.rb, 改为如下的形式

```ruby
require 'rubygems'
gem 'backup2qiniu'
require 'backup2qiniu'

Backup::Model.new(:mysql_backup_qiniu, 'example backup to qiniu') do
  split_into_chunks_of 4

  # more info: https://github.com/meskyanichi/backup/wiki/Databases
  database MySQL do |db|
    db.name               = "DATABASE_NAME"
    db.username           = "BACKUP_USERNAME"
    db.password           = "BACKUP_PASSWORD"
    db.host               = "localhost"
    db.port               = 3306
    db.socket             = "/tmp/mysql.sock"
  end

  store_with Qiniu do |q|
    ## when using uploadToken, you can not delete the old backup (for security concern)
    # q.keep = 7
    q.upload_token = 'REPLACE WITH UPLOAD TOKEN'
    q.bucket = 'BUCKET_NAME'
    q.path = 'BACKUP_DIR1'
  end

  store_with Qiniu do |q|
    q.keep = 7
    q.access_key = 'REPLACE WITH ACCESS KEY'
    q.access_secret = 'REPLACE WITH ACCESS SECRET'
    q.bucket = 'BUCKET_NAME'
    q.path = 'BACKUP_DIR2'
  end

  # more info: https://github.com/meskyanichi/backup/wiki/Encryptors
  encrypt_with GPG do |encryption|
    encryption.keys = {}
    encryption.keys['YOUR EMAIL'] = <<-KEY
      -----BEGIN PGP PUBLIC KEY BLOCK-----
      Version: GnuPG v1.4.12 (Darwin)

      YOUR KEY
      -----END PGP PUBLIC KEY BLOCK-----
    KEY
    encryption.recipients = ['YOUR EMAIL']
  end
end
```

* 运行 backup perform -t mysql_backup_qiniu
* backup 支持备份目录，数据库等多种源，并且支持非对称密钥加密来保护数据安全，
   具体可以参考 backup 的文档: https://github.com/meskyanichi/backup
