require 'capistrano/recipes/deploy/strategy/copy'
require 'fileutils'
require 'tempfile'
require 'pty'

module Capistrano
  module Deploy
    module Strategy
      class Mason < Copy
        def build(directory)
          execute "Building with mason" do
            streaming_system("mason build #{ directory } -t tgz -o #{ File.basename(filename) }")
          end
        end

        private
        def streaming_system(cmd)
          PTY.spawn(cmd) { |stdout, _, _| stdout.each { |line| logger.trace(line) } }
        end

        # A struct for representing the specifics of a compression type.
        # Commands are arrays, where the first element is the utility to be
        # used to perform the compression or decompression.
        Compression = Struct.new(:extension, :compress_command, :decompress_command)

        # The compression method to use, defaults to :gzip.
        def compression
          remote_tar = configuration[:copy_remote_tar] || 'tar'
          local_tar = configuration[:copy_local_tar] || 'tar'

          Compression.new("tar.gz",  [local_tar, 'czf'], [remote_tar, 'xzf'])
        end
      end
    end
  end
end
