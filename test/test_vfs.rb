require 'helper'
require 'stringio'

module SQLite3
  class TestVFS < SQLite3::TestCase

    class MyVFS < SQLite3::VFS
      def open name, flags
        MyVFSFile.new name, flags
      end
    end

    class MyVFSFile < SQLite3::VFS::File
      def initialize name, flags
        super
        @name = name
        @locks = Hash.new(0)
        @mutex = Mutex.new
        # puts "init: #{name} #{flags}"
        @store = ::StringIO.new
      end

      def close
        # puts "close: #{@name}"
        @store.close
      end

      def read amount, offset
        # puts "read: #{@name} #{amount} #{offset}"
        @store.seek offset
        @store.read amount
      end

      def write data, offset
        # puts "write: #{@name} #{data.length} #{offset}"
        @store.seek offset
        @store.write data
      end

      def truncate bytes
        # puts "truncate: #{@name} #{bytes}"
        @store.truncate bytes
      end

      def sync flags
        # puts "sync: #{@name} #{flags}"
        @store.fsync
      end

      def file_size
        # puts "file_size: #{@name}"
        @store.size
      end

      def reserved_lock?
        # puts "reserved_lock?: #{@name}"
        @mutex.synchronize do
          [LOCK_RESERVED, LOCK_PENDING, LOCK_EXCLUSIVE].any? do |type|
            @locks[type] > 0
          end
        end
      end

      def unlock mode
        # puts "unlock: #{@name} #{mode}"
        @mutex.synchronize do
          @locks[mode] -= 1
        end
      end

      def lock mode
        # puts "lock: #{@name} #{mode}"
        @mutex.synchronize do
          @locks[mode] += 1
        end
      end

      def sector_size
        # puts "sector_size: #{@name}"
        SQLite3::VFS::DEFAULT_SECTOR_SIZE
      end

      def characteristics
        # puts "chars: #{@name}"
        0 # TODO: What is this?
      end
    end

    SQLite3.vfs_register(MyVFS.new)

    def test_my_vfs
      SQLite3::Database.new('foo', {}, 'SQLite3::TestVFS::MyVFS')
      exit 0
    end

    def test_my_vfs_create_table
      db = SQLite3::Database.new('foo', {}, 'SQLite3::TestVFS::MyVFS')
      db.execute('create table ex(id int, data string)')
    end

    def test_read_write
      db = SQLite3::Database.new('foo', {}, 'SQLite3::TestVFS::MyVFS')
      db.execute('create table ex(id int, data string)')
      db.execute('insert into ex(id, data) VALUES (1, "foo")')
      assert_equal([[1, "foo"]], db.execute('select id, data from ex'))
    end

    def test_truncate
      db = SQLite3::Database.new('foo', {}, 'SQLite3::TestVFS::MyVFS')
      db.execute('PRAGMA auto_vacuum = 1')
      db.execute('create table ex(id int, data string)')
      db.execute('insert into ex(id, data) VALUES (1, "foo")')
      db.execute('drop table ex')
    end

  end
end
