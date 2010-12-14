require File.expand_path("../lib/version", __FILE__)

Gem::Specification.new do | s |

  s.name = 'capistrano_s3'
  s.version = Capistrano_S3::Version::STRING
  s.platform = Gem::Platform::RUBY
  s.summary = "A deployment strategy for capistrano using S3"
  s.description = "A deployment strategy for capistrano using S3"

  s.files = Dir.glob("{bin,lib,examples,test}/**/*") + %w(README MIT-LICENSE)
  s.has_rdoc = true

  s.add_dependency 'capistrano', ">= 2.1.0"
  s.add_dependency 's3sync'

  s.authors = ["Bill Kirtley", "Matt Griffin"]
  s.email = ["bill.kirtley@gmail.com", "matt@griffinonline.org"]
  s.rubyforge_project = 'capistrano_s3'
  s.homepage = "http://github.com/cluesque/capistrano-s3"
end
