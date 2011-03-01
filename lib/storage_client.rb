# encoding: utf-8
# StorageClient
# This is a ruby wrapper for the soundcloud API
#
# Author:: Johannes Wagener (johannes@wagener.cc)

require 'rubygems'

# gem 'oauth', '>= 0.3.6'
require 'oauth'

# gem 'oauth-active-resource'
require 'oauth_active_resource'


module StorageClient

  def self.client
    site = config['site']
    @client ||= register({:access_token => access_token,:site => site })
  end

  def self.access_token
    @access_token ||= OAuth::AccessToken.new(consumer, config['access_token'], config['access_secret'])
  end

  def self.all_config
    @all_config ||= YAML::load_file(Rails.root.join("config","storage_client.yml"))
  end

  def self.config
    @config ||= all_config[Rails.env]
  end

  def self.bucket
    @bucket ||= Bucket.find bucket_id
  end

  def self.bucket_id
    @bucket_id ||= config['bucket']
  end

  def self.build_file(file,attributes = {})
    attributes.merge! :bucket_id => bucket_id
    attributes.delete :file
    file_object = client.FileObject.new attributes
    file_object.file = file
    file_object
  end

  # Will create an OAuth Consumer for you.
  #
  # You have to register your application on soundcloud.com to get a consumer token and secret.
  #
  # Optionally you can specify another provider site (i.e. http://api.sandbox-soundcloud.com)
  #
  # Default provider site is http://api.soundcloud.com
  def self.consumer
    site = config['site'] if config['site']
    consumer_token = config['consumer_token']
    consumer_secret = config['consumer_secret']
    @consumer ||= OAuth::Consumer.new(consumer_token, consumer_secret, {
      :site               => site,
      :request_token_path => "/oauth/request_token",
      :access_token_path  => "/oauth/access_token",
      :authorize_path     => "/oauth/authorize"
    })
  end


  # Will create a soundcloud module containing all the soundcloud models.
  # This module is bound to the given OAuth access token.
  #
  # Options:
  #  :access_token = your oauth access token
  #  :site = soundcloud api site (i.e. "http://api.sandbox-soundcloud.com", defaults to "http://api.soundcloud.com")
  # Examples:
  #
  #   # unauthenticated to "http://api.soundcloud.com"
  #   cl = Soundcloud.register()
  #
  #   # authenticated connection to soundcloud sandbox
  #   cl = Soundcloud.register({:access_token => your_access_token, :site => "http://api.sandbox-soundcloud.com"})
  #
  def self.register(options = {})
    options[:site] = options[:site] || 'http://storage.railser.com'
    if options[:consumer_key].nil? && options[:access_token].nil?
      raise "Error:  No consumer key or OAuth access token supplied."
    end
    mod = SCOAuthActiveResource.register(self.ancestors.first, self.ancestors.first.const_get('Models'),options)
    add_resolver_to_mod(mod)
  end
  
  # Quick hack to add support api.soundcloud.com/resolve . TODO jw cleanup :)
  def self.add_resolver_to_mod(mod)
    mod.module_eval do
      def self.resolve(url)
        base = self.const_get('Base')
        response = base.oauth_connection.get("/resolve?url=#{url}")
        if response.code == "302"
          path = URI.parse(response.header['Location']).path
          resource_class = base.new.send(:find_or_create_resource_for_collection, path.split('/')[-2])
          resource_class.find(:one, :from => path)
        else
          raise ActiveResource::ResourceNotFound.new(response)
        end
      end
    end
    mod
  end
end

require File.expand_path('../storage_client/models/base',     __FILE__)
require File.expand_path('../storage_client/models/user',     __FILE__)
require File.expand_path('../storage_client/models/bucket',     __FILE__)
require File.expand_path('../storage_client/models/file_object',     __FILE__)
require File.expand_path('../storage_client/sc_oauth_active_resource', __FILE__)
