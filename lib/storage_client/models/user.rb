# encoding: utf-8
module StorageClient
  module Models
    class User < Base
      has_many :buckets,:file_objects
      cattr_accessor :data_attributes
      self.data_attributes = ["avatar"]
      # has_many_single_changeable :contacts, :favorites
      # can_be_a_single_changeable :contact
      
      cattr_accessor :element_name      
      self.element_name = 'user'

      # Convenience method to find the logged in user
      def self.find_me
        find(:one, :from => '/me')
      end
    end
    
  end
end

