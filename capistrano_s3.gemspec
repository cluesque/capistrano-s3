Gem::Specification.new do |s|

  s.name = 'capistrano_s3'
  s.version = PKG_VERSION
  s.platform = Gem::Platform::RUBY
  s.summary = "A deployment strategy for capistrano using S3"
  s.description = "A deployment strategy for capistrano using S3"

  s.files = Dir.glob("{bin,lib,examples,test}/**/*") + %w(README MIT-LICENSE)
  s.has_rdoc = true

  s.add_dependency 'capistrano', ">= 2.1.0"
  s.add_dependency 's3sync'

  s.author = "Bill Kirtley"
  s.email = "bill@virosity.com"
  s.rubyforge_project = "capistrano-s3"
  s.homepage = "http://virosity.com"
end
