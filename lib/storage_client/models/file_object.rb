module StorageClient
  module Models

    class FileObject < Base
      # has_many_single_changeable :contacts, :favorites
      # can_be_a_single_changeable :contact
      cattr_accessor :data_attributes
      self.data_attributes = [:file]
      
      cattr_accessor :element_name      
      self.element_name = 'file_object'
      belongs_to :user
      belongs_to :bucket

      self.prefix = "/buckets/:bucket_id/"


      def file=(args)
        file,content_type = args
        content_type ||= "text/plain"
        raise "File Not Exists: #{file}" unless File.exists?(file)
        self.content_type = content_type
        self.name = File.basename(file)
        self.file_content = Base64.encode64(File.read(file))
        file
      end

      # Convenience method to find the logged in user
      def self.find_me
        find(:one, :from => '/me')
      end
    end
    
  end
end

