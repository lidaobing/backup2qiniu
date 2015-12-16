# Backup2qiniu

[![Join the chat at https://gitter.im/lidaobing/backup2qiniu](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/lidaobing/backup2qiniu?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

备份你的数据、文件到 [qiniu.com](http://www.qiniu.com/)

## 使用方法

* 运行 gem install backup2qiniu
* 运行 backup generate:config
* 运行 backup generate:model --trigger=mysql_backup_qiniu
* 运行 backup2qiniu gen_token 来生成配置文件
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

  # 把这段替换为你刚刚生成的配置文件
  store_with Qiniu do |q|
    ## when using uploadToken, you can not delete the old backup (for security concern)
    # q.keep = 7
    q.upload_token = 'REPLACE WITH UPLOAD TOKEN'
    q.bucket = 'BUCKET_NAME'
    q.path = 'BACKUP_DIR1'
  end

  # 如果需要自动删除过期的备份，那么需要直接使用 https://portal.qiniu.com/setting/key 拿到的 AK 和 SK
  # store_with Qiniu do |q|
  #   q.keep = 7
  #   q.access_key = 'REPLACE WITH ACCESS KEY'       # 从网页拿到的 AK
  #   q.access_secret = 'REPLACE WITH ACCESS SECRET' # 从网页拿到的 SK
  #   q.bucket = 'BUCKET_NAME'
  #   q.path = 'BACKUP_DIR2'
  # end

  # 为安全起见我们推荐你生成一对 GPG 秘钥，用公钥来加密你的数据库备份
  # 更多信息: https://github.com/meskyanichi/backup/wiki/Encryptors
  # encrypt_with GPG do |encryption|
  #   encryption.keys = {}
  #   encryption.keys['YOUR EMAIL'] = <<-KEY
  #     -----BEGIN PGP PUBLIC KEY BLOCK-----
  #     Version: GnuPG v1.4.12 (Darwin)
  #
  #     YOUR KEY
  #     -----END PGP PUBLIC KEY BLOCK-----
  #   KEY
  #   encryption.recipients = ['YOUR EMAIL']
  # end
end
```

* 运行 backup perform -t mysql_backup_qiniu
* backup 支持备份目录，数据库等多种源，并且支持非对称密钥加密来保护数据安全，
   具体可以参考 backup 的文档: https://github.com/meskyanichi/backup
