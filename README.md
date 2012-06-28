# Backup2qiniu

备份你的数据、文件到 [qiniutek.com](http://www.qiniutek.com/)

## 使用方法

* 运行 gem install backup2qiniu
* 运行 backup generate:config
* 运行 backup generate:model --trigger=mysql_backup_qiniu
* 修改 ~/Backup/models/mysql_backup_qiniu.rb, 改为如下的形式

```
require 'rubygems'
gem 'backup2qiniu'
require 'backup2qiniu'

Backup::Model.new(:mysql_backup_qiniu, 'example backup to qiniu') do
  split_into_chunks_of 250

  database MySQL do |db|
    db.name               = "for_backup"
    db.username           = "my_username"
    db.password           = "my_password"
    db.host               = "localhost"
    db.port               = 3306
    db.socket             = "/tmp/mysql.sock"
  end

  store_with Qiniu do |eb|
    eb.username = 'username'
    eb.password = 's3cret'
    eb.bucket = 'backup'
  end
end
```

* 运行 sudo backup perform -t mysql_backup_qiniu
* backup 支持备份目录，数据库等多种源，并且支持非对称密钥加密来保护数据安全，
   具体可以参考 backup 的文档: https://github.com/meskyanichi/backup
