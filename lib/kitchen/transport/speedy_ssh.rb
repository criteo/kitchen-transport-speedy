require_relative 'speedy'
require 'kitchen/transport/ssh'

module Kitchen
  module Transport
    class SpeedySsh < Ssh

      kitchen_transport_api_version 1
      plugin_version SpeedyModule::VERSION

      def log_prefix
        "SSH"
      end

      include SpeedyBase

      class Connection < Ssh::Connection
        include SpeedyConnectionBase

        def valid_local_requirements?
          !Mixlib::ShellOut.new("which tar > /dev/null").run_command.error?
        end

        def valid_remote_requirements?
          begin
            execute("which tar > /dev/null")
            true
          rescue => e
            logger.debug(e)
          end
        end

        def archive_locally(path, archive_path)
          "tar -cf #{archive_path} -C #{::File.dirname(path)} #{::File.basename(path)}"
        end

        def dearchive_remotely(archive_basename, remote)
          "tar -xf #{::File.join(remote, archive_basename)} -C #{remote}"
        end
      end

    end
  end
end
