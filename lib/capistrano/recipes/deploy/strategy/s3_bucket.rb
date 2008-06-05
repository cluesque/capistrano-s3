require 'capistrano/recipes/deploy/strategy/copy'
require 'fileutils'
require 'tempfile'  # Dir.tmpdir

#implementing a capistrano deploy strategy that:
# - Expects a deploy_bucket it can read from and write to
# - Uses configuration[:s3_config] to find creds
# - Names releases {application}_{revision}.tgz
# - Looks in the bucket for a file with that name - skip to actual deployment if found
# - Checks out the specified revision, bundles it up, and pushes to the S3 bucket
# - depends on the s3cmd command, perhaps installed with `gem install s3sync`

# Copyright 2008 Bill Kirtley, Virosity Inc.
# Distributed via MIT license
# Feedback appreciated: bill at [nospam] virosity dt com

module Capistrano
  module Deploy
    module Strategy

      class S3Bucket < Copy

        def deploy!
          logger.debug "getting (via #{copy_strategy}) revision #{revision} to #{destination}"
          logger.debug "#{configuration[:release_path]} #{File.basename(configuration[:release_path])}"
          put_package
          
          run "#{aws_environment} s3cmd get #{bucket_name}:#{package_name} #{remote_filename}"
          run "mkdir #{configuration[:release_path]} && cd #{configuration[:release_path]} && #{decompress(remote_filename).join(" ")} && rm #{remote_filename}"
          logger.debug "done!"
        end

        #!! implement me!
        # Performs a check on the remote hosts to determine whether everything
        # is setup such that a deploy could succeed.
        # def check!
        # end

    private
        def aws_environment
          @aws_environment ||= "AWS_ACCOUNT_NUMBER=#{configuration[:s3_config]['AWS_ACCOUNT_NUMBER']} AWS_ACCESS_KEY_ID=#{configuration[:s3_config]['AWS_ACCESS_KEY_ID']} AWS_SECRET_ACCESS_KEY=#{configuration[:s3_config]['AWS_SECRET_ACCESS_KEY']}"
        end
        # Responsible for ensuring that the package for the current revision is in the bucket
        def put_package
          set :release_name, revision
          logger.debug "#{package_name} already in bucket #{bucket_name}" and return if bucket_includes_package
          logger.debug "#{package_name} not found in bucket #{bucket_name} so ckout to add it"
          
          # Do the checkout locally
          system(command)
          File.open(File.join(destination, "REVISION"), "w") { |f| f.puts(revision) }

          # Compress it
          logger.trace "compressing in #{destination}"
          logger.trace compress('*', package_path).join(" ")

          Dir.chdir(destination) { system(compress('*', package_path).join(" ")) }

          # Put to S3
          logger.trace "pushing to S3 bucket #{bucket_name} key #{package_name}"
          system("s3cmd put #{bucket_name}:#{package_name} #{package_path}")
        end

        def bucket_includes_package
          /#{package_name}/.match(`s3cmd list #{bucket_name}:#{package_name}`)
        end

        def package_name
          @package_name ||= "#{configuration[:application]}_#{revision}.tgz"
        end
        
        def package_path
          @package_path ||= File.join(tmpdir, package_name)
        end
        
        def bucket_name
          configuration[:deploy_s3_bucket]
        end
        
        def bucket
          @bucket ||= Bucket.find(bucket_name) or raise "Failed to find bucket #{configuration[:deploy_s3_bucket]}"
        end

        def initialize(config={})
          super(config)
          
          raise "Failed to find :s3_config" unless configuration[:s3_config]
          # Annoying that merge doesnt work because ENV isn't really a Hash:
          # ENV.merge(configuration[:s3_config])
          configuration[:s3_config].each_pair { |name, value| ENV[name] = value }
        end

      end
    end
  end
end