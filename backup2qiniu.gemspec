# -*- encoding: utf-8 -*-
require File.expand_path('../lib/backup2qiniu/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["LI Daobing"]
  gem.email         = ["lidaobing@gmail.com"]
  gem.description   = %q{backup to qiniutek.com}
  gem.summary       = %q{backup to qiniutek.com}
  gem.homepage      = "https://github.com/lidaobing/backup2qiniu"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "backup2qiniu"
  gem.require_paths = ["lib"]
  gem.version       = Backup2qiniu::VERSION
  gem.add_dependency 'backup', '~> 3.1.0'
  gem.add_dependency 'qiniu-rs', '~> 3.1'
end
