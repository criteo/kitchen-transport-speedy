require_relative 'speedy'
require 'kitchen/transport/ssh'

module Kitchen
  module Transport
    class SpeedySsh < Ssh

      kitchen_transport_api_version 1
      plugin_version SpeedyModule::VERSION

      def finalize_config!(instance)
        super.tap do
          if defined?(Kitchen::Verifier::Inspec) && instance.verifier.is_a?(Kitchen::Verifier::Inspec)
            instance.verifier.send(:define_singleton_method, :runner_options_for_speedyssh) do |config_data|
              runner_options_for_ssh(config_data)
            end
          end
        end
      end

      def log_prefix
        "SSH"
      end

      include SpeedyBase

      class Connection < Ssh::Connection
        include SpeedyConnectionBase

        def valid_local_requirements?
          !Mixlib::ShellOut.new("which tar > /dev/null").run_command.error?
          !Mixlib::ShellOut.new("which gzip > /dev/null").run_command.error?
        end

        def valid_remote_requirements?
          begin
            execute("which tar > /dev/null")
            execute("which gzip > /dev/null")
            true
          rescue => e
            logger.debug(e)
          end
        end

        def ensure_remotedir_exists(remote)
          "mkdir -p #{remote}"
        end

        def archive_locally(path, archive_path)
          "tar -czf #{archive_path} -C #{::File.dirname(path)} #{::File.basename(path)}"
        end

        def dearchive_remotely(archive_basename, remote)
          "tar -xzf #{::File.join(remote, archive_basename)} -C #{remote}"
        end
      end

    end
  end
end
