require 'capistrano/recipes/deploy/strategy/copy'
require 'fileutils'
require 'tempfile'
require 'pty'

module Capistrano
  module Deploy
    module Strategy
      class Mason < Copy

        def deploy!
          copy_cache ? run_copy_cache_strategy : run_copy_strategy

          build!
          create_revision_file
          distribute!
        ensure
          rollback_changes
        end

        def build!
          execute "Building with mason" do
            streaming_system("mason build #{ destination } -c ~/.mason/cache/#{configuration[:application]} -t tgz -o #{ filename }")
          end
        end

        private
        def streaming_system(cmd)
          begin
            PTY.spawn(cmd) { |stdout, _, _|
              begin
                stdout.each { |line| logger.trace(line) }
              rescue Errno::EIO => ex
                # NOOP: IO stream ended.
              end
            }
          rescue PTY::ChildExited
            # Some BS rescue as per the internetz
          end
        end

        def run_copy_cache_strategy
          copy_repository_to_local_cache
          copy_cache_to_staging_area
        end

        def run_copy_strategy
          copy_repository_to_server
          remove_excluded_files if copy_exclude.any?
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

        def decompress_remote_file
          run "mkdir #{ configuration[:release_path] } && cd #{ configuration[:release_path] } && #{decompress(remote_filename).join(" ")} && rm #{remote_filename}"
        end
      end
    end
  end
end
