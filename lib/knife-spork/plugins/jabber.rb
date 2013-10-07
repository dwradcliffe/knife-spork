require 'knife-spork/plugins/plugin'

module KnifeSpork
  module Plugins
    class Jabber < Plugin
      name :jabber

      def perform; end

      def after_upload
        jabber "#{organization}#{current_user} uploaded the following cookbooks:\n#{cookbooks.collect{ |c| "  #{c.name}@#{c.version}" }.join("\n")}"
      end

      def after_promote_remote
        jabber "#{organization}#{current_user} promoted the following cookbooks:\n#{cookbooks.collect{ |c| "  #{c.name}@#{c.version}" }.join("\n")} to #{environments.collect{ |e| "#{e.name}" }.join(", ")}"
      end

      def after_rolefromfile
        jabber "#{organization}#{current_user} uploaded role #{object_name}"
      end

      def after_roleedit
        jabber "#{organization}#{current_user} edited role #{object_name}"
      end

      def after_rolecreate
        jabber "#{organization}#{current_user} created role #{object_name}"
      end

      def after_roledelete
        jabber "#{organization}#{current_user} deleted role #{object_name}"
      end

      def after_databagedit
        jabber "#{organization}#{current_user} edited data bag item #{object_name}:#{object_secondary_name}"
      end

      def after_databagcreate
        jabber "#{organization}#{current_user} created data bag #{object_name}"
      end

      def after_databagdelete
        jabber "#{organization}#{current_user} deleted data bag #{object_name}"
      end

      def after_databagitemdelete
        jabber "#{organization}#{current_user} deleted data bag item #{object_name}:#{object_secondary_name}"
      end

      def after_databagfromfile
        jabber "#{organization}#{current_user} uploaded data bag item #{object_name}:#{object_secondary_name}"
      end

      private

      def jabber(message)
        safe_require 'xmpp4r'
        safe_require 'xmpp4r/muc/helper/simplemucclient'

        client = ::Jabber::Client.new(config.username)
        client.connect(host = config.server_name, port = config.server_port ||= '5222')
        client.auth(config.password)

        rooms.each do |room_name|
          begin
            conference = ::Jabber::MUC::SimpleMUCClient.new(client)
            conference.join("#{room_name}/#{nickname}")
            conference.say(message)
          rescue Exception => e
            ui.error 'Something went wrong sending to Jabber.'
            ui.error e.to_s
          end
        end
      end

      def rooms
        [ config.room || config.rooms ].flatten
      end

      def nickname
        config.nickname || 'KnifeSpork'
      end
    end
  end
end
