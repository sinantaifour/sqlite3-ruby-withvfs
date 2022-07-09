require 'stringio'
require 'thread'

module SQLite3
  class VFS
    class File
      def initialize name, flags
        @name  = name
        @flags = flags
      end

      ###
      # Close the file
      def close
        raise NotImplementedError
      end

      ###
      # Read +amount+ from +offset+
      def read amount, offset
        raise NotImplementedError
      end

      ###
      # Write +data+ at +offset+
      def write data, offset
        raise NotImplementedError
      end

      ###
      # Truncate the data store to +bytes+
      def truncate bytes
        raise NotImplementedError
      end

      ###
      # Sync the IO
      def sync flags
        raise NotImplementedError
      end

      ###
      # Returns the file size for the underlying IO
      def file_size
        raise NotImplementedError
      end

      def reserved_lock?
        raise NotImplementedError
      end

      def unlock mode
        raise NotImplementedError
      end

      def lock mode
        raise NotImplementedError
      end

      def sector_size
        raise NotImplementedError
      end

      def characteristics
        raise NotImplementedError
      end
    end
  end
end
