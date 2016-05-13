require "kitchen/transport/speedy/version"
require 'kitchen'
require 'kitchen/transport/ssh'

require 'mixlib/shellout'

module Kitchen
  module Transport
    class Speedy < Ssh
      kitchen_transport_api_version 1
      plugin_version SpeedyModule::VERSION

      # copy paste from ssh transport
      # see https://github.com/test-kitchen/test-kitchen/pull/726
      def create_new_connection(options, &block)
        if @connection
          logger.debug("[SSH] shutting previous connection #{@connection}")
          @connection.close
        end

        @connection_options = options
        @connection = self.class::Connection.new(options, &block)
      end

      class Connection < Ssh::Connection
        def upload(locals, remote)

          tar_exists_locally = !Mixlib::ShellOut.new("which tar > /dev/null").run_command.error?
          tar_exists_remotely = begin
                                  execute("which tar")
                                  true
                                rescue => e
                                  logger.debug(e)
                                end
          unless tar_exists_locally && tar_exists_remotely
            logger.debug("Calling back default implementation since tar cannot be found either locally or in the box")
            return super
          end

          locals.each do |local|
            if ::File.directory?(local)
              file_count = ::Dir.glob(::File.join(local, '**/*')).size
              logger.debug("#{local} contains #{file_count}")
              archive_basename = ::File.basename(local) + '.tar'
              archive = ::File.join(::File.dirname(local), archive_basename)
              Mixlib::ShellOut.new("tar -cf #{archive} -C #{::File.dirname(local)} #{::File.basename(local)}").run_command.error!


              logger.debug("Calling regular upload for #{archive} to #{remote}")
              super(archive, remote)
              execute("tar -xf #{::File.join(remote, archive_basename)} -C #{remote}")
            else
              logger.debug("Calling regular upload for #{local}")
              super(local, remote)
            end
          end
        end
      end

    end
  end
end
