require File.dirname(__FILE__) + '/test_helper'

require 'capistrano/logger'
require 'capistrano/recipes/deploy/strategy/s3_bucket'
require 'stringio'

context "Capistrano::Deploy::Strategy::S3Bucket" do
  def setup
    logger = Capistrano::Logger.new(:output => StringIO.new)
    # Uncomment this line to see the output a cap user would see for debugging
    # logger = Capistrano::Logger.new
    logger.level = Capistrano::Logger::MAX_LEVEL
    @config = { :application => "testapp",
                :logger => logger,
                :releases_path => "/u/apps/test/releases",
                :release_path => "/u/apps/test/releases/1234567890",
                :real_revision => "154",
                :deploy_s3_bucket => 'com.example.bucket',
                :s3_config => {'AWS_ACCOUNT_NUMBER' => '1234-5678-9012', 
                               'AWS_ACCESS_KEY_ID' => 'ABCDEFGHIJKLMNOPQRST', 
                               'AWS_SECRET_ACCESS_KEY' => 'abcdefghijklmnopqrstuvwxyz01234567890ABC' }
                 }
    @source = mock("source")
    @config.stubs(:source).returns(@source)
    @config.stubs(:set)
    @strategy = Capistrano::Deploy::Strategy::S3Bucket.new(@config)
    Dir.stubs(:tmpdir).returns("/temp/dir")
  end

  specify "does not push to S3 if already there" do
    @strategy.expects(:`).returns("--------------------\ncom.example.bucket:testapp_154.tgz")
    prepare_deploy
    @strategy.deploy!
  end

  specify "does push to S3 if not already there" do
    @strategy.expects(:`).returns("--------------------\n")    
    prepare_deploy
    @source.expects(:checkout).with("154", "/temp/dir/1234567890").returns(:local_checkout)
    @strategy.expects(:system).with(:local_checkout)
    File.expects(:open).with('/temp/dir/1234567890/REVISION', 'w')
    Dir.expects(:chdir).with("/temp/dir/1234567890").yields
    @strategy.expects(:system).with('tar czf /temp/dir/testapp_154.tgz *')
    @strategy.expects(:system).with('s3cmd put com.example.bucket:testapp_154.tgz /temp/dir/testapp_154.tgz')
    @strategy.deploy!
  end

private

  def aws_credential_envs
    "AWS_ACCOUNT_NUMBER=1234-5678-9012 AWS_ACCESS_KEY_ID=ABCDEFGHIJKLMNOPQRST AWS_SECRET_ACCESS_KEY=abcdefghijklmnopqrstuvwxyz01234567890ABC"
  end

  # These are expected for any deploy
  def prepare_deploy
    @strategy.expects(:run).with("#{aws_credential_envs} s3cmd get com.example.bucket:testapp_154.tgz /tmp/1234567890.tar.gz")
    @strategy.expects(:run).with("mkdir /u/apps/test/releases/1234567890 && cd /u/apps/test/releases/1234567890 && tar xzf /tmp/1234567890.tar.gz && rm /tmp/1234567890.tar.gz")
  end

end 
 
  