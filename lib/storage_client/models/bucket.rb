# encoding: utf-8
module StorageClient
  module Models

    class Bucket < Base
      # has_many_single_changeable :contacts, :favorites
      # can_be_a_single_changeable :contact
      
      cattr_accessor :element_name      
      self.element_name = 'bucket'
      belongs_to :user
      has_many   :file_objects

      # Convenience method to find the logged in user
      def self.find_me
        find(:one, :from => '/me')
      end
    end
    
  end
end

