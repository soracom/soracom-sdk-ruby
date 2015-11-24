# coding: utf-8

require 'thor'
require 'open-uri'

module SoracomCli
  # SIM related commands
  class Subscriber < Thor
    desc 'list', 'list Subscriber(SIM)s'
    option :limit, type: :numeric, required: false, desc: 'max number of result(default:1024)'
    option :filter, type: :hash, required: false, desc: 'ex) --filter key:imsi value:001010000000001 / --filter key:tagname value:tagvalue'
    def list
      client = Soracom::Client.new
      sims = client.list_subscribers(Hash[options.map { |k, v| [k.to_sym, v] }])
      puts JSON.pretty_generate(sims)
    end

    desc 'register', 'register Subscriber(SIM)'
    option :registration_secret, type: :string, required: true, desc: 'Registration Secret, 5 digits'
    option :imsi, type: :string, required: true, desc: 'SIM unique ID, 15 digits'
    option :type, type: :string, desc: 'default plan type'
    option :tags, type: :hash, desc: 'tag as hash i.e. --tags name:"foo" group:"bar"'
    def register
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.register_subscriber(Hash[options.map { |k, v| [k.to_sym, v] }]))
    end

    desc 'activate', 'activate Subscriber(SIM)s'
    option :imsi, type: :array, required: true
    def activate
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.activate_subscriber(options[:imsi]))
    end

    desc 'deactivate', 'deactivate Subscriber(SIM)s'
    option :imsi, type: :array, required: true
    def deactivate
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.deactivate_subscriber(options[:imsi]))
    end

    desc 'terminate', 'terminate Subscriber(SIM)s'
    option :imsi, type: :array, required: true
    option :confirm, type: :string
    def terminate
      abort 'You may not revert terminate opereation. Please add "--confirm YES" if you are sure.' if options[:confirm] != 'YES'
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.terminate_subscriber(options[:imsi]))
    end

    desc 'enable_termination', 'enable termination of Subscriber(SIM)s'
    option :imsi, type: :array, required: true
    def enable_termination
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.enable_termination(options[:imsi]))
    end

    desc 'disable_termination', 'disable termination of Subscriber(SIM)s'
    option :imsi, type: :array, required: true
    def disable_termination
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.disable_termination(options[:imsi]))
    end

    desc 'update_tags', 'add or update tags for Subscriber(SIM)s'
    option :imsi, type: :array, required: true
    option :tags, type: :hash, required: true
    def update_tags
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.update_subscriber_tags(options[:imsi], options[:tags]))
    end

    desc 'delete_tag', 'delete tag for Subscriber(SIM)s'
    option :imsi, type: :array, required: true
    option :tag_name, type: :string, required: true
    def delete_tag
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.delete_subscriber_tag(options[:imsi], options[:tag_name]))
    end

    desc 'update_speed_class', 'change speed class for Subscriber(SIM)s'
    option :imsi, type: :array, required: true
    option :speed_class, type: :string, required: true
    def update_speed_class
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.update_subscriber_speed_class(options[:imsi], options[:speed_class]))
    end

    desc 'set_expiry_time', 'update expiry time of Subscriber(SIM)s'
    option :imsi, type: :array, required: true
    option :expiry_time, type: :numeric, required: true
    def set_expiry_time
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.set_expiry_time(options[:imsi], options[:expiry_time]))
    end

    desc 'unset_expiry_time', 'delete expiry time of Subscriber(SIM)s'
    option :imsi, type: :array, required: true
    def unset_expiry_time
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.unset_expiry_time(options[:imsi]))
    end

    desc 'set_group', 'set group of Subscriber(SIM)'
    option :imsi, type: :string, required: true
    option :group_id, type: :string, required: true
    def set_group
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.set_group(options[:imsi], options[:group_id]))
    end

    desc 'unset_group', 'unset group of Subscriber(SIM)'
    option :imsi, type: :string, required: true
    def unset_group
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.unset_group(options[:imsi]))
    end
  end
  
  # Group related commands
  class Group < Thor
    desc 'list', 'list groups'
    option :group_id, type: :string, desc: 'group ID'
    def list
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.list_groups(options.group_id))
    end
    
    desc 'list_subscribers', 'list subscriber in a group'
    option :group_id, type: :string, required:true, desc: 'group ID'
    def list_subscribers
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.list_subscribers_in_group(options.group_id))
    end
    
    desc 'create', 'create group'
    option :tags, type: :hash, desc: 'group tags'
    def create
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.create_group(options.tags))
    end
    
    desc 'delete_group', 'delete a group'
    option :group_id, type: :string, required:true, desc: 'group ID'
    def delete
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.delete_group(options.group_id))
    end
    
    desc 'update_configuration', 'update configuration parameter'
    option :group_id, type: :string, required:true, desc: 'group ID'
    option :namespace, type: :string, required:true, desc: 'namespace of the parameter'
    option :params, type: :string, required:true, desc: 'JSON string of the configuration parameter'
    def update_configuration
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.update_group_configuration(options.group_id, options.namespace, options.params))
    end
    
    desc 'delete_configuration', 'delete configuration parameter'
    option :group_id, type: :string, required:true, desc: 'group ID'
    option :namespace, type: :string, required:true, desc: 'namespace of the parameter'
    option :name, type: :string, required:true, desc: 'name of configuration parameter to delete'
    def delete_configuration
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.delete_group_configuration(options.group_id, options.namespace, options.name))
    end

    desc 'update_tags', 'update group tags'
    option :group_id, type: :string, required:true, desc: 'group ID'
    option :tags, type: :string, required:true, desc: 'JSON string of tags i.e. [{"tagName":"name","tagValue":"new group name"}]'
    def update_tags
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.update_group_tags(options.group_id, options.tags))
    end
    
    desc 'delete_tag', 'delete group tag'
    option :group_id, type: :string, required:true, desc: 'group ID'
    option :name, type: :string, required:true, desc: 'tag name to delete'
    def delete_tag
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.delete_group_tags(options.group_id, options.name))
    end
  end
  
  # EventHandler related commands
  class EventHandler < Thor
    desc 'list', 'list event handlers'
    option :handler_id, type: :string, desc: 'group ID'
    option :imsi, type: :string, desc: 'SIM unique ID, 15 digits'
    option :target, type: :string, desc: 'target can be operator/imsi/tag'
    def list
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.list_event_handlers(Hash[options.map { |k, v| [k.to_sym, v] }]))
    end
        
    desc 'create', 'create event handler'
    option :req, type: :string, desc: 'JSON string of event handler configuration'
    def create
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.create_event_handler(options.req))
    end
    
    desc 'delete', 'delete event handler'
    option :handler_id, type: :string, required:true, desc: 'Event Handler ID'
    def delete
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.delete_event_handler(options.handler_id))
    end
    
    desc 'update', 'update event handler configuration'
    option :handler_id, type: :string, required:true, desc: 'Event Handler ID'
    option :req, type: :string, desc: 'JSON string of event handler configuration'
    def update
      client = Soracom::Client.new
      puts JSON.pretty_generate(client.update_event_handler(options.handler_id, options.req))
    end
  end
  
  # Stats related commands
  class Stats < Thor
    desc 'get_air_usage', 'get air usage per Subscriber(SIM)'
    option :imsi, type: :string, required: true, desc: '15 digits SIM unique ID'
    option :from, type: :numeric, required: false, desc: 'UNIX time in seconds when stat window begins'
    option :to, type: :numeric, required: false, desc: 'UNIX time in seconds when stat window ends'
    option :period, type: :string, required: false, desc: 'miniutes or day or month'
    def get_air_usage
      client = Soracom::Client.new
      data = client.get_air_usage(Hash[options.map { |k, v| [k.to_sym, v] }])
      puts JSON.pretty_generate(data)
    end
    
    desc 'get_beam_usage', 'get beam usage per Subscriber(SIM)'
    option :imsi, type: :string, required: true, desc: '15 digits SIM unique ID'
    option :from, type: :numeric, required: false, desc: 'UNIX time in seconds when stat window begins'
    option :to, type: :numeric, required: false, desc: 'UNIX time in seconds when stat window ends'
    option :period, type: :string, required: false, desc: 'miniutes or day or month'
    def get_beam_usage
      client = Soracom::Client.new
      data = client.get_beam_usage(Hash[options.map { |k, v| [k.to_sym, v] }])
      puts JSON.pretty_generate(data)
    end
    
    desc 'export_air_usage', 'export air usage for all Subscriber(SIM)s in csv format'
    option :from, type: :numeric, required: false, desc: 'UNIX time in seconds when stat window begins'
    option :to, type: :numeric, required: false, desc: 'UNIX time in seconds when stat window ends'
    option :period, type: :string, required: false, desc: 'miniutes or day or month'
    def export_air_usage
      client = Soracom::Client.new
      csv = client.export_air_usage(Hash[options.map { |k, v| [k.to_sym, v] }])
      puts csv
    end
    
    desc 'export_beam_usage', 'export beam usage for all Subscriber(SIM)s in csv format'
    option :from, type: :numeric, required: false, desc: 'UNIX time in seconds when stat window begins'
    option :to, type: :numeric, required: false, desc: 'UNIX time in seconds when stat window ends'
    option :period, type: :string, required: false, desc: 'miniutes or day or month'
    def export_beam_usage
      client = Soracom::Client.new
      csv = client.export_beam_usage(Hash[options.map { |k, v| [k.to_sym, v] }])
      puts csv
    end
  end

  # Using Thor for CLI Implementation
  class CLI < Thor
    register(Subscriber, 'subscriber', 'subscriber <command>', 'Subscriber related operations')
    register(Subscriber, 'sim', 'sim <command>', 'Subscriber related operations(alias)')
    register(Group, 'group', 'group <command>', 'Group related operations')
    register(EventHandler, 'event_handler', 'event_handler <command>', 'Event Handler related operations')
    register(Stats, 'stats', 'stats <command>', 'Stats related operations')

    desc 'auth', 'test authentication'
    def auth
      puts 'testing authentication...'
      begin
        client = Soracom::Client.new
        puts <<EOS
authentication succeeded.
apiKey: #{client.api_key}
operatorId: #{client.operator_id}
token: #{client.token}
EOS
      rescue => evar
        abort 'ERROR: ' + evar.to_s
      end
    end

    desc 'support', 'open support site'
    def support
      client = Soracom::Client.new
      url = client.get_support_url
      system "open '#{url}' &> /dev/null || ( echo open following URL in your browser. ; echo '#{url}' )"
    end

    desc 'version', 'print version'
    def version
      puts "Soracom API tool v#{Soracom::VERSION}"
    end

    desc 'complete', 'command list for shell completion'
    def complete
      commands = CLI.commands.select { |k, _v| k != 'complete' }.map { |k, _v| k }.join(' ')
      subcommands = {}
      CLI.subcommand_classes.each { |k, v| subcommands[k] = v.commands.map { |k2, _v2| k2 } }
      subcommands_string = subcommands.map do |k, v|
        <<EOS
  [ "$3" = "#{k}" ] && COMPREPLY=( $( compgen -W "#{v.join(' ')}" ${COMP_WORDS[COMP_CWORD]} ) )
EOS
      end.join
      print <<EOS
_soracom()
{
  [ "$3" = "soracom" ] && COMPREPLY=( $( compgen -W "#{commands}" ${COMP_WORDS[COMP_CWORD]} ) )
#{subcommands_string}
}
complete -F _soracom soracom
EOS
    end
  end
end
