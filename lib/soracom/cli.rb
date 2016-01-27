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
      client = Soracom::Client.new(profile:options.profile)
      options.delete('profile')
      sims = client.list_subscribers(Hash[options.map { |k, v| [k.to_sym, v] }])
      puts JSON.pretty_generate(sims)
    end

    desc 'register', 'register Subscriber(SIM)'
    option :registration_secret, type: :string, required: true, desc: 'Registration Secret, 5 digits'
    option :imsi, type: :string, required: true, desc: 'SIM unique ID, 15 digits'
    option :type, type: :string, desc: 'default plan type'
    option :tags, type: :hash, desc: 'tag as hash i.e. --tags name:"foo" group:"bar"'
    def register
      client = Soracom::Client.new(profile:options.profile)
      options.delete('profile')
      puts JSON.pretty_generate(client.register_subscriber(Hash[options.map { |k, v| [k.to_sym, v] }]))
    end

    desc 'activate', 'activate Subscriber(SIM)s'
    option :imsi, type: :array, required: true
    def activate
      client = Soracom::Client.new(profile:options.profile)
      puts JSON.pretty_generate(client.activate_subscriber(options[:imsi]))
    end

    desc 'deactivate', 'deactivate Subscriber(SIM)s'
    option :imsi, type: :array, required: true
    def deactivate
      client = Soracom::Client.new(profile:options.profile)
      puts JSON.pretty_generate(client.deactivate_subscriber(options[:imsi]))
    end

    desc 'terminate', 'terminate Subscriber(SIM)s'
    option :imsi, type: :array, required: true
    option :confirm, type: :string
    def terminate
      abort 'You may not revert terminate opereation. Please add "--confirm YES" if you are sure.' if options[:confirm] != 'YES'
      client = Soracom::Client.new(profile:options.profile)
      puts JSON.pretty_generate(client.terminate_subscriber(options[:imsi]))
    end

    desc 'enable_termination', 'enable termination of Subscriber(SIM)s'
    option :imsi, type: :array, required: true
    def enable_termination
      client = Soracom::Client.new(profile:options.profile)
      puts JSON.pretty_generate(client.enable_termination(options[:imsi]))
    end

    desc 'disable_termination', 'disable termination of Subscriber(SIM)s'
    option :imsi, type: :array, required: true
    def disable_termination
      client = Soracom::Client.new(profile:options.profile)
      puts JSON.pretty_generate(client.disable_termination(options[:imsi]))
    end

    desc 'update_tags', 'add or update tags for Subscriber(SIM)s'
    option :imsi, type: :array, required: true
    option :tags, type: :hash, required: true
    def update_tags
      client = Soracom::Client.new(profile:options.profile)
      puts JSON.pretty_generate(client.update_subscriber_tags(options[:imsi], options[:tags]))
    end

    desc 'delete_tag', 'delete tag for Subscriber(SIM)s'
    option :imsi, type: :array, required: true
    option :tag_name, type: :string, required: true
    def delete_tag
      client = Soracom::Client.new(profile:options.profile)
      puts JSON.pretty_generate(client.delete_subscriber_tag(options[:imsi], options[:tag_name]))
    end

    desc 'update_speed_class', 'change speed class for Subscriber(SIM)s'
    option :imsi, type: :array, required: true
    option :speed_class, type: :string, required: true
    def update_speed_class
      client = Soracom::Client.new(profile:options.profile)
      puts JSON.pretty_generate(client.update_subscriber_speed_class(options[:imsi], options[:speed_class]))
    end

    desc 'set_expiry_time', 'update expiry time of Subscriber(SIM)s'
    option :imsi, type: :array, required: true
    option :expiry_time, type: :numeric, required: true
    def set_expiry_time
      client = Soracom::Client.new(profile:options.profile)
      puts JSON.pretty_generate(client.set_expiry_time(options[:imsi], options[:expiry_time]))
    end

    desc 'unset_expiry_time', 'delete expiry time of Subscriber(SIM)s'
    option :imsi, type: :array, required: true
    def unset_expiry_time
      client = Soracom::Client.new(profile:options.profile)
      puts JSON.pretty_generate(client.unset_expiry_time(options[:imsi]))
    end

    desc 'set_group', 'set group of Subscriber(SIM)'
    option :imsi, type: :string, required: true
    option :group_id, type: :string, required: true
    def set_group
      client = Soracom::Client.new(profile:options.profile)
      puts JSON.pretty_generate(client.set_group(options[:imsi], options[:group_id]))
    end

    desc 'unset_group', 'unset group of Subscriber(SIM)'
    option :imsi, type: :string, required: true
    def unset_group
      client = Soracom::Client.new(profile:options.profile)
      puts JSON.pretty_generate(client.unset_group(options[:imsi]))
    end
  end

  # Group related commands
  class Group < Thor
    desc 'list', 'list groups'
    option :group_id, type: :string, desc: 'group ID'
    def list
      client = Soracom::Client.new(profile:options.profile)
      puts JSON.pretty_generate(client.list_groups(options.group_id))
    end

    desc 'list_subscribers', 'list subscriber in a group'
    option :group_id, type: :string, required:true, desc: 'group ID'
    def list_subscribers
      client = Soracom::Client.new(profile:options.profile)
      puts JSON.pretty_generate(client.list_subscribers_in_group(options.group_id))
    end

    desc 'create', 'create group'
    option :tags, type: :hash, desc: 'group tags'
    def create
      client = Soracom::Client.new(profile:options.profile)
      puts JSON.pretty_generate(client.create_group(options.tags))
    end

    desc 'delete_group', 'delete a group'
    option :group_id, type: :string, required:true, desc: 'group ID'
    def delete
      client = Soracom::Client.new(profile:options.profile)
      puts JSON.pretty_generate(client.delete_group(options.group_id))
    end

    desc 'update_configuration', 'update configuration parameter'
    option :group_id, type: :string, required:true, desc: 'group ID'
    option :namespace, type: :string, required:true, desc: 'namespace of the parameter'
    option :params, type: :string, required:true, desc: 'JSON string of the configuration parameter'
    def update_configuration
      if options.params=~/^[a-z]+:\/\/(.+)/
        begin
          content = open(options.params.sub(/^file:\/\//,'')).read
          options['params'] = content
        rescue Errno::ENOENT
        rescue SocketError
          abort "ERROR: Cannot access #{options.params}."
        end
      end
      client = Soracom::Client.new(profile:options.profile)
      puts JSON.pretty_generate(client.update_group_configuration(options.group_id, options.namespace, options.params))
    end

    desc 'delete_configuration', 'delete configuration parameter'
    option :group_id, type: :string, required:true, desc: 'group ID'
    option :namespace, type: :string, required:true, desc: 'namespace of the parameter'
    option :name, type: :string, required:true, desc: 'name of configuration parameter to delete'
    def delete_configuration
      client = Soracom::Client.new(profile:options.profile)
      puts JSON.pretty_generate(client.delete_group_configuration(options.group_id, options.namespace, options.name))
    end

    desc 'update_tags', 'update group tags'
    option :group_id, type: :string, required:true, desc: 'group ID'
    option :tags, type: :string, required:true, desc: 'JSON string of tags i.e. [{"tagName":"name","tagValue":"new group name"}]'
    def update_tags
      client = Soracom::Client.new(profile:options.profile)
      puts JSON.pretty_generate(client.update_group_tags(options.group_id, options.tags))
    end

    desc 'delete_tag', 'delete group tag'
    option :group_id, type: :string, required:true, desc: 'group ID'
    option :name, type: :string, required:true, desc: 'tag name to delete'
    def delete_tag
      client = Soracom::Client.new(profile:options.profile)
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
      client = Soracom::Client.new(profile:options.profile)
      options.delete('profile')
      puts JSON.pretty_generate(client.list_event_handlers(Hash[options.map { |k, v| [k.to_sym, v] }]))
    end

    desc 'create', 'create event handler'
    option :req, type: :string, desc: 'JSON string of event handler configuration'
    def create
      if options.req=~/^[a-z]+:\/\/(.+)/
        begin
          content = open(options.req.sub(/^file:\/\//,'')).read
          options['req'] = content
        rescue Errno::ENOENT
        rescue SocketError
          abort "ERROR: Cannot access #{options.req}."
        end
      end
      client = Soracom::Client.new(profile:options.profile)
      puts JSON.pretty_generate(client.create_event_handler(options.req))
    end

    desc 'delete', 'delete event handler'
    option :handler_id, type: :string, required:true, desc: 'Event Handler ID'
    def delete
      client = Soracom::Client.new(profile:options.profile)
      puts JSON.pretty_generate(client.delete_event_handler(options.handler_id))
    end

    desc 'update', 'update event handler configuration'
    option :handler_id, type: :string, required:true, desc: 'Event Handler ID'
    option :req, type: :string, desc: 'JSON string of event handler configuration'
    def update
      if options.req=~/^[a-z]+:\/\/(.+)/
        begin
          content = open(options.req.sub(/^file:\/\//,'')).read
          options['req'] = content
        rescue Errno::ENOENT
        rescue SocketError
          abort "ERROR: Cannot access #{options.req}."
        end
      end
      client = Soracom::Client.new(profile:options.profile)
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
      client = Soracom::Client.new(profile:options.profile)
      options.delete('profile')
      data = client.get_air_usage(Hash[options.map { |k, v| [k.to_sym, v] }])
      puts JSON.pretty_generate(data)
    end

    desc 'get_beam_usage', 'get beam usage per Subscriber(SIM)'
    option :imsi, type: :string, required: true, desc: '15 digits SIM unique ID'
    option :from, type: :numeric, required: false, desc: 'UNIX time in seconds when stat window begins'
    option :to, type: :numeric, required: false, desc: 'UNIX time in seconds when stat window ends'
    option :period, type: :string, required: false, desc: 'miniutes or day or month'
    def get_beam_usage
      client = Soracom::Client.new(profile:options.profile)
      options.delete('profile')
      data = client.get_beam_usage(Hash[options.map { |k, v| [k.to_sym, v] }])
      puts JSON.pretty_generate(data)
    end

    desc 'export_air_usage', 'export air usage for all Subscriber(SIM)s in csv format'
    option :from, type: :numeric, required: false, desc: 'UNIX time in seconds when stat window begins'
    option :to, type: :numeric, required: false, desc: 'UNIX time in seconds when stat window ends'
    option :period, type: :string, required: false, desc: 'miniutes or day or month'
    def export_air_usage
      client = Soracom::Client.new(profile:options.profile)
      csv = client.export_air_usage(Hash[options.map { |k, v| [k.to_sym, v] }])
      puts csv
    end

    desc 'export_beam_usage', 'export beam usage for all Subscriber(SIM)s in csv format'
    option :from, type: :numeric, required: false, desc: 'UNIX time in seconds when stat window begins'
    option :to, type: :numeric, required: false, desc: 'UNIX time in seconds when stat window ends'
    option :period, type: :string, required: false, desc: 'miniutes or day or month'
    def export_beam_usage
      client = Soracom::Client.new(profile:options.profile)
      options.delete('profile')
      csv = client.export_beam_usage(Hash[options.map { |k, v| [k.to_sym, v] }])
      puts csv
    end
  end

  # Operator related commands
  class Operator < Thor
    desc 'list_auth_keys', 'list auth keys for Operator'
    def list_auth_keys
      client = Soracom::Client.new(profile:options.profile)
      data = client.list_operator_auth_keys()
      puts JSON.pretty_generate(data)
    end

    desc 'generate_auth_key', 'generate new auth key for Operator'
    def generate_auth_key
      client = Soracom::Client.new(profile:options.profile)
      data = client.generate_operator_auth_key()
      puts JSON.pretty_generate(data)
    end

    desc 'delete_auth_key', 'delete existing auth key for Operator'
    option :auth_key_id, type: :string, required: true, desc: 'auth key id starting "keyId-"'
    def delete_auth_key
      client = Soracom::Client.new(profile:options.profile)
      data = client.delete_operator_auth_key(options.auth_key_id)
      puts JSON.pretty_generate(data)
    end
  end

  # User related commands
  class User < Thor
    desc 'list_users', 'list users under Operator'
    def list_users
      client = Soracom::Client.new(profile:options.profile)
      data = client.list_users()
      puts JSON.pretty_generate(data)
    end

    desc 'delete_user', 'delete user under Operator'
    option :user_name, required: true, desc: 'User name'
    def delete_user
      client = Soracom::Client.new(profile:options.profile)
      data = client.delete_user(options.user_name)
      puts JSON.pretty_generate(data)
    end

    desc 'get_user', 'get user info under Operator'
    option :user_name, desc: 'User name'
    def get_user
      client = Soracom::Client.new(profile:options.profile)
      data = client.get_user(options.user_name)
      puts JSON.pretty_generate(data)
    end

    desc 'create_user', 'create user under Operator'
    option :user_name, required: true, desc: 'User name'
    option :description, desc: 'description for the user'
    def create_user
      client = Soracom::Client.new(profile:options.profile)
      data = client.create_user(options.user_name, options.description)
      puts JSON.pretty_generate(data)
    end

    desc 'update_user', 'update user under Operator'
    option :user_name, required: true, desc: 'User name'
    option :description, desc: 'description for the user'
    def update_user
      client = Soracom::Client.new(profile:options.profile)
      data = client.update_user(options.user_name, options.description)
      puts JSON.pretty_generate(data)
    end

    desc 'list_auth_keys', 'list auth keys for user'
    option :user_name, desc: 'User name'
    def list_auth_keys
      client = Soracom::Client.new(profile:options.profile)
      data = client.list_users_auth_key(options.user_name)
      puts JSON.pretty_generate(data)
    end

    desc 'generate_auth_key', 'generate new auth key for user'
    option :user_name, desc: 'User name'
    def generate_auth_key
      client = Soracom::Client.new(profile:options.profile)
      data = client.generate_users_auth_key(options.user_name)
      puts JSON.pretty_generate(data)
    end

    desc 'delete_auth_key', 'delete existing auth key for user'
    option :user_name, desc: 'User name'
    option :auth_key_id, type: :string, required: true, desc: 'auth key id starting "keyId-"'
    def delete_auth_key
      client = Soracom::Client.new(profile:options.profile)
      data = client.delete_users_auth_key(options.user_name, options.auth_key_id)
      puts JSON.pretty_generate(data)
    end

    desc 'get_auth_key', 'get auth key info for user'
    option :user_name, desc: 'User name'
    option :auth_key_id, type: :string, required: true, desc: 'auth key id starting "keyId-"'
    def get_auth_key
      client = Soracom::Client.new(profile:options.profile)
      data = client.get_users_auth_key(options.user_name, options.auth_key_id)
      puts JSON.pretty_generate(data)
    end

    desc 'delete_password', 'delete existing password for user'
    option :user_name, desc: 'User name'
    def delete_password
      client = Soracom::Client.new(profile:options.profile)
      data = client.delete_user_password(options.user_name)
      puts JSON.pretty_generate(data)
    end

    desc 'has_password', 'check if the user has password'
    option :user_name, desc: 'User name'
    def has_password
      client = Soracom::Client.new(profile:options.profile)
      data = client.has_user_password(options.user_name)
      puts JSON.pretty_generate(data)
    end

    desc 'create_password', 'create passwod for the user'
    option :user_name, desc: 'User name'
    option :password, desc: 'Password for the user'
    def create_password
      client = Soracom::Client.new(profile:options.profile)
      data = client.create_user_password(options.user_name, options.password)
      puts JSON.pretty_generate(data)
    end

    desc 'get_permission', 'get permission for the user'
    option :user_name, desc: 'User name'
    def get_permission
      client = Soracom::Client.new(profile:options.profile)
      data = client.get_user_permission(options.user_name)
      puts JSON.pretty_generate(data)
    end

    desc 'upadte_permission', 'update permission for the user'
    option :user_name, desc: 'User name'
    option :permission, required:true, desc: 'Permission string for the user'
    option :description, desc: 'Description for the permission'
    def update_permission
      client = Soracom::Client.new(profile:options.profile)
      data = client.update_user_permission(options.user_name, options.permission, options.description)
      puts JSON.pretty_generate(data)
    end

  end

  # Role related commands
  class Role < Thor
    desc 'list_roles', 'list roles'
    def list_roles
      client = Soracom::Client.new(profile:options.profile)
      data = client.list_roles()
      puts JSON.pretty_generate(data)
    end

    desc 'delete_roles', 'delete role'
    option :role_id, required: true, desc: 'ID of the role'
    def delete_role
      client = Soracom::Client.new(profile:options.profile)
      data = client.delete_role()
      puts JSON.pretty_generate(data)
    end

    desc 'get_role', 'get information of role'
    option :role_id, required: true, desc: 'ID of the role'
    def get_role
      client = Soracom::Client.new(profile:options.profile)
      data = client.get_role(options.role_id)
      puts JSON.pretty_generate(data)
    end

    desc 'create_role', 'create a role'
    option :role_id, required: true, desc: 'ID of the role'
    option :permission, required: true, desc: 'Permission for the role'
    option :description, desc: 'Descroption for the role'
    def create_role
      client = Soracom::Client.new(profile:options.profile)
      data = client.create_role(options.role_id, options.permission, options.description)
      puts JSON.pretty_generate(data)
    end

    desc 'update_role', 'update existing role'
    option :role_id, required: true, desc: 'ID of the role'
    option :permission, required: true, desc: 'Permission for the role'
    option :description, desc: 'Descroption for the role'
    def update_role
      client = Soracom::Client.new(profile:options.profile)
      data = client.update_role(options.role_id, options.permission, options.description)
      puts JSON.pretty_generate(data)
    end

    desc 'list_role_attached_users', 'list users having a role attached'
    def list_role_attached_users
      client = Soracom::Client.new(profile:options.profile)
      data = client.list_role_attached_users
      puts JSON.pretty_generate(data)
    end

    desc 'list_user_roles', 'list roles attached to a user'
    option :user_name, required: true, desc: 'user name'
    def list_user_roles
      client = Soracom::Client.new(profile:options.profile)
      data = client.list_user_roles(options.user_name)
      puts JSON.pretty_generate(data)
    end

    desc 'attach_role_to_user', 'attach role to user'
    option :user_name, required: true, desc: 'user name'
    option :role_id, required: true, desc: 'role_id'
    def attach_role_to_user
      client = Soracom::Client.new(profile:options.profile)
      data = client.attach_role_to_user(options.user_name, options.role_id)
      puts JSON.pretty_generate(data)
    end

    desc 'delete_role_from_user', 'delete role from user'
    option :user_name, required: true, desc: 'user name'
    option :role_id, required: true, desc: 'role_id'
    def delete_role_from_user
      client = Soracom::Client.new(profile:options.profile)
      data = client.delete_role_from_user(options.user_name, options.role_id)
      puts JSON.pretty_generate(data)
    end

  end

  # Using Thor for CLI Implementation
  class CLI < Thor
    class_option :profile, default: 'default', desc: 'profile to use, stored in $HOME/.soracom/PROFILE.json'

    register(Subscriber, 'subscriber', 'subscriber <command>', 'Subscriber related operations')
    register(Subscriber, 'sim', 'sim <command>', 'Subscriber related operations(alias)')
    register(Group, 'group', 'group <command>', 'Group related operations')
    register(EventHandler, 'event_handler', 'event_handler <command>', 'Event Handler related operations')
    register(Stats, 'stats', 'stats <command>', 'Stats related operations')
    register(Operator, 'operator', 'operator <command>', 'Operator related operations')
    register(User, 'user', 'user <command>', 'SAM User related operations')
    register(Role, 'role', 'role <command>', 'Role related operations')

    desc 'auth', 'test authentication'
    def auth
      puts "testing authentication... #{options.profile}"
      begin
        client = Soracom::Client.new(profile:options.profile)
        puts <<EOS
authentication succeeded.
apiKey: #{client.api_key}
operatorId: #{client.operator_id}
userName: #{client.user_name}
token: #{client.token}
EOS
      rescue => evar
        abort 'ERROR: ' + evar.to_s
      end
    end

    desc 'configure', 'setup soracom environment'
    def configure
      print <<EOS
--- SORACOM CLI setup ---
This will create .soracom directory under #{ENV['HOME']} and place '#{options.profile}.json' in it.

Please select which authentication method to use.

1. Input AuthKeyId and AuthKey *Recommended*
2. Input Operator credentials (Operator Email and Password)
3. Input SAM credentials (OperatorId and UserName and Password)

EOS
      mode = STDIN.tap{print "select(1-3)> "}.gets.chomp
      begin
        Dir.mkdir("#{ENV['HOME']}/.soracom/",0700)
      rescue Errno::EEXIST
      end
      case mode
      when '1'
        authKeyId = STDIN.tap{print "authKeyId: "}.gets.chomp
        authKey = STDIN.tap{print "authKey: "}.noecho(&:gets).tap{print "\n"}.chomp
        File.open("#{ENV['HOME']}/.soracom/#{options.profile}.json", "w") do |f|
          f.print JSON.pretty_generate ({authKeyId: authKeyId, authKey: authKey})
        end
      when '2'
        email = STDIN.tap{print "Email: "}.gets.chomp
        password = STDIN.tap{print "Password: "}.noecho(&:gets).tap{print "\n"}.chomp
        File.open("#{ENV['HOME']}/.soracom/#{options.profile}.json", "w") do |f|
          f.print JSON.pretty_generate ({email: email, password: password})
        end
      when '3'
        operatorId = STDIN.tap{print "operatorId: "}.gets.chomp
        userName = STDIN.tap{print "userName: "}.gets.chomp
        password = STDIN.tap{print "password: "}.noecho(&:gets).tap{print "\n"}.chomp
        File.open("#{ENV['HOME']}/.soracom/#{options.profile}.json", "w") do |f|
          f.print JSON.pretty_generate ({operatorId: operatorId, userName: userName, password: password})
        end
      else
        abort "invalid number."
      end
      print "wrote to #{ENV['HOME']}/.soracom/#{options.profile}.json\n"
    end

    desc 'support', 'open support site'
    def support
      client = Soracom::Client.new(profile:options.profile)
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
