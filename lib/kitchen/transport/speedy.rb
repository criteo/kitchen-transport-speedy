require "kitchen/transport/speedy/version"
require 'kitchen'

require 'mixlib/shellout'

module Kitchen
  module Transport

    module SpeedyBase
      # require :log_prefix
      # copy paste from ssh transport
      # see https://github.com/test-kitchen/test-kitchen/pull/726
      def create_new_connection(options, &block)
        if @connection
          logger.debug("[#{log_prefix}] shutting previous connection #{@connection}")
          @connection.close
        end

        @connection_options = options
        @connection = self.class::Connection.new(options, &block)
      end
    end

    module SpeedyConnectionBase

      def valid_local_requirements?
        raise NotImplementedError
      end

      def valid_remote_requirements?
        raise NotImplementedError
      end

      def archive_locally(path, archive_path)
        raise NotImplementedError
      end

      def  dearchive_remotely(archive_basename, remote)
        raise NotImplementedError
      end

      def upload(locals, remote)
        unless valid_local_requirements? && valid_remote_requirements?
          logger.debug("Calling back default implementation since requirements cannot be validate locally and in the box")
          return super
        end

        Array(locals).each do |local|
          if ::File.directory?(local)
            file_count = ::Dir.glob(::File.join(local, '**/*')).size
            logger.debug("#{local} contains #{file_count}")
            archive_basename = ::File.basename(local) + '.tgz'
            archive = ::File.join(::File.dirname(local), archive_basename)
            Mixlib::ShellOut.new(archive_locally(local, archive)).run_command.error!
            execute(ensure_remotedir_exists(remote))

            logger.debug("Calling regular upload for #{archive} to #{remote}")
            super(archive, remote)
            execute(dearchive_remotely(archive_basename, remote))
          else
            logger.debug("Calling regular upload for #{local} since it is a simple file")
            super(local, remote)
          end
        end
      end
    end
  end
end
