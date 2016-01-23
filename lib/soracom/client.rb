require 'net/http'
require 'uri'
require 'cgi'
require 'json'
require 'base64'
require 'ostruct'
require 'logger'

# SORACOM gem implementation
module Soracom
  API_BASE_URL = 'https://api.soracom.io/v1'
  # Soracom API Client
  class Client
    # 設定されなかった場合には、環境変数から認証情報を取得
    def initialize(
        endpoint:ENV['SORACOM_ENDPOINT'],
        email:ENV['SORACOM_EMAIL'], password:ENV['SORACOM_PASSWORD'],
        auth_key_id:ENV['SORACOM_AUTH_KEY_ID'], auth_key:ENV['SORACOM_AUTH_KEY']
      )
      @log = Logger.new(STDERR)
      @log.level = ENV['SORACOM_DEBUG'] ? Logger::DEBUG : Logger::WARN
      begin
        if auth_key_id && auth_key
          @auth = auth_by_key(auth_key_id, auth_key, endpoint)
        elsif email && password
          @auth = auth(email, password, endpoint)
        else
          fail 'Could not find any credentials(authKeyId & authKey or email & password)'
        end
      rescue => evar
        abort 'ERROR: ' + evar.to_s
      end
      @api = Soracom::ApiClient.new(@auth, endpoint)
    end

    # 特定Operator下のSubscriber一覧を取
    def list_subscribers(operatorId:@auth[:operatorId], limit:1024, filter:{})
      filter = Hash[filter.map { |k, v| [k.to_sym, v] }]
      if filter[:key].nil?
        return @api.get(path: '/subscribers', params: { operatorId: operatorId, limit: limit })
      end

      # filterありの場合
      case filter[:key]
      when 'imsi'
        [@api.get(path: "/subscribers/#{filter[:value]}", params: { operatorId: operatorId, limit: limit })]
      when 'msisdn'
        [@api.get(path: "/subscribers/msisdn/#{filter[:value]}", params: { operatorId: operatorId, limit: limit })]
      when 'status'
        @api.get(path: '/subscribers', params: { operatorId: operatorId, limit: limit, status_filter: filter[:value].gsub('|', '%7C') })
      when 'speed_class'
        @api.get(path: '/subscribers', params: { operatorId: operatorId, limit: limit, speed_class_filter: filter[:value] })
      else
        @api.get(path: '/subscribers', params: { operatorId: operatorId, limit: limit, tag_name: filter[:key], tag_value: filter[:value], tag_value_match_mode: filter[:mode] || 'exact' })
      end
    end

    def subscribers(operatorId:@auth[:operatorId], limit:1024, filter:{})
      list_subscribers(operatorId: operatorId, limit: limit, filter: filter).map { |s| Soracom::Subscriber.new(s, self) }
    end

    # SIMの登録
    def register_subscriber(imsi:nil, registration_secret:nil, groupId:nil, tags:{})
      params = { registrationSecret: registration_secret, tags: tags }
      params[groupId] = groupId if groupId
      @api.post(path: "/subscribers/#{imsi}", payload: params)
    end

    # SIMの利用開始(再開)
    def activate_subscriber(imsis)
      imsis = [imsis] if imsis.class != Array
      threads = [], result = []
      imsis.map do |imsi|
        threads << Thread.new do
          result << { 'imsi' => imsi }.merge(@api.post(path: "/subscribers/#{imsi}/activate"))
        end
      end
      threads.each(&:join)
      result
    end

    # SIMの利用休止
    def deactivate_subscriber(imsis)
      imsis = [imsis] if imsis.class != Array
      threads = [], result = []
      imsis.map do |imsi|
        threads << Thread.new do
          result << { 'imsi' => imsi }.merge(@api.post(path: "/subscribers/#{imsi}/deactivate"))
        end
      end
      threads.each(&:join)
      result
    end

    # SIMの解約
    def terminate_subscriber(imsis)
      imsis = [imsis] if imsis.class != Array
      threads = [], result = []
      imsis.map do |imsi|
        threads << Thread.new do
          result << { 'imsi' => imsi }.merge(@api.post(path: "/subscribers/#{imsi}/terminate"))
        end
      end
      threads.each(&:join)
      result
    end

    # 指定されたSubscriberをTerminate可能に設定する
    def enable_termination(imsis)
      imsis = [imsis] if imsis.class != Array
      threads = [], result = []
      imsis.map do |imsi|
        threads << Thread.new do
          result << { 'imsi' => imsi }.merge(@api.post(path: "/subscribers/#{imsi}/enable_termination"))
        end
      end
      threads.each(&:join)
      result
    end

    # 指定されたSubscriberをTerminate不可能に設定する
    def disable_termination(imsis)
      imsis = [imsis] if imsis.class != Array
      threads = [], result = []
      imsis.map do |imsi|
        threads << Thread.new do
          result << { 'imsi' => imsi }.merge(@api.post(path: "/subscribers/#{imsi}/disable_termination"))
        end
      end
      threads.each(&:join)
      result
    end

    # タグの更新
    def update_subscriber_tags(imsis, tags)
      imsis = [imsis] if imsis.class != Array
      threads = [], result = []
      imsis.map do |imsi|
        threads << Thread.new do
          result << { 'imsi' => imsi }.merge(@api.post(path: "/subscribers/#{imsi}/update_tags", payload: tags))
        end
      end
      threads.each(&:join)
      result
    end

    # 指定タグの削除
    def delete_subscriber_tag(imsis, tag_name)
      imsis = [imsis] if imsis.class != Array
      threads = [], result = []
      imsis.map do |imsi|
        threads << Thread.new do
          result << { 'imsi' => imsi }.merge(@api.delete(path: "/subscribers/#{imsi}/tags/#{CGI.escape(tag_name)}"))
        end
      end
      threads.each(&:join)
      result
    end

    # SIMのプラン変更
    def update_subscriber_speed_class(imsis, speed_class)
      imsis = [imsis] if imsis.class != Array
      threads = [], result = []
      imsis.map do |imsi|
        threads << Thread.new do
          result << { 'imsi' => imsi }.merge(@api.post(path: "/subscribers/#{imsi}/update_speed_class", payload: { speedClass: speed_class }))
        end
      end
      threads.each(&:join)
      result
    end

    # SIMの有効期限設定
    def set_expiry_time(imsis, expiry_time)
      imsis = [imsis] if imsis.class != Array
      threads = [], result = []
      imsis.map do |imsi|
        threads << Thread.new do
          result << { 'imsi' => imsi }.merge(@api.post(path: "/subscribers/#{imsi}/set_expiry_time", payload: { expiryTime: expiry_time }))
        end
      end
      threads.each(&:join)
      result
    end

    # SIMの有効期限設定を解除
    def unset_expiry_time(imsis)
      imsis = [imsis] if imsis.class != Array
      threads = [], result = []
      imsis.map do |imsi|
        threads << Thread.new do
          result << { 'imsi' => imsi }.merge(@api.post(path: "/subscribers/#{imsi}/unset_expiry_time"))
        end
      end
      threads.each(&:join)
      result
    end

    # SIMの所属Groupを指定あるいは上書き変更
    def set_group(imsi, group_id)
      @api.post(path: "/subscribers/#{imsi}/set_group", payload: { groupId: group_id })
    end

    # SIMの所属Groupを指定を解除
    def unset_group(imsi)
      @api.post(path: "/subscribers/#{imsi}/unset_group")
    end

    # SIMグループの一覧を取得
    def list_groups(group_id)
      if group_id
        [ @api.get(path: "/groups/#{group_id}") ]
      else
        @api.get(path: '/groups')
      end
    end

    # SIMグループを新規作成
    def create_group(tags=nil)
      payload = (tags) ? { tags: tags } : {}
      @api.post(path: '/groups', payload: payload)
    end

    # SIMグループの削除
    def delete_group(group_id)
      @api.delete(path: "/groups/#{group_id}")
    end

    # SIMグループの削除
    def list_subscribers_in_group(group_id)
      @api.get(path: "/groups/#{group_id}/subscribers")
    end

    # コンフィグパラメータの更新
    def update_group_configuration(group_id, namespace, params)
      params = transform_json(params)
      @api.put(path: "/groups/#{group_id}/configuration/#{namespace}", payload: params)
    end

    # コンフィグパラメータ内の設定を削除
    def delete_group_configuration(group_id, namespace, name)
      @api.delete(path: "/groups/#{group_id}/configuration/#{namespace}/#{name}")
    end

    # コンフィグパラメータの更新
    def update_group_tags(group_id, tags = {})
      @api.put(path: "/groups/#{group_id}/tags", payload: tags)
    end

    # コンフィグパラメータ内の設定を削除
    def delete_group_tags(group_id, name)
      @api.delete(path: "/groups/#{group_id}/tags/#{name}")
    end

    # イベントハンドラーの一覧を得る
    def list_event_handlers(handler_id:nil, target:nil, imsi:nil)
      if handler_id
        [@api.get(path: "/event_handlers/#{handler_id}")]
      elsif imsi
        @api.get(path: "/event_handlers/subscribers/#{imsi}")
      elsif target # target is one of imsi/operator/tag
        @api.get(path: '/event_handlers', params: { target: target })
      else
        @api.get(path: "/event_handlers")
      end
    end

    # イベントハンドラーを新規作成する
    def create_event_handler(req)
      req = transform_json req
      @api.post(path: '/event_handlers', payload: req)
    end

    # イベントハンドラーの情報を得る
    def get_event_handler(handler_id)
      @api.get(path: "/event_handlers/#{handler_id}")
    end

    # イベントハンドラーを削除する
    def delete_event_handler(handler_id)
      @api.delete(path: "/event_handlers/#{handler_id}")
    end

    # イベントハンドラーを更新する
    def update_event_handler(handler_id, req)
      req = transform_json req
      @api.put(path: "/event_handlers/#{handler_id}", payload: req)
    end

    # Subscriber毎のAir使用状況を得る(デフォルトでは直近１日)
    def get_air_usage(imsi:nil, from:(Time.now.to_i - 24 * 60 * 60), to:Time.now.to_i, period:'minutes')
      @api.get(path: "/stats/air/subscribers/#{imsi}", params: { from: from, to: to, period: period })
    end

    # Subscriber毎のBeam使用状況を得る(デフォルトでは直近１日)
    def get_beam_usage(imsi:nil, from:(Time.now.to_i - 24 * 60 * 60), to:Time.now.to_i, period:'minutes')
      @api.get(path: "/stats/beam/subscribers/#{imsi}", params: { from: from, to: to, period: period })
    end

    # Operator配下の全Subscriberに関するAir使用状況をダウンロードする(デフォルトでは今月)
    def export_air_usage(operator_id:@auth[:operatorId] , from:Time.parse("#{Time.now.year}-#{Time.now.month}-#{Time.now.day}").to_i, to:Time.now.to_i, period:'day')
      res = @api.post(path: "/stats/air/operators/#{operator_id}/export", payload: { from: from, to: to, period: period })
      open(res['url']).read
    end

    # Operator配下の全Subscriberに関するBeam使用状況をダウンロードする(デフォルトでは今月)
    def export_beam_usage(operator_id:@auth[:operatorId] , from:Time.parse("#{Time.now.year}-#{Time.now.month}-#{Time.now.day}").to_i, to:Time.now.to_i, period:'day')
      res = @api.post(path: "/stats/beam/operators/#{operator_id}/export", payload: { from: from, to: to, period: period })
      open(res['url']).read
    end

    # サポートサイトのURLを取得
    def get_support_url(return_to: 'https://soracom.zendesk.com/hc/ja/requests')
      res = @api.post(path: "/operators/#{@auth[:operatorId]}/support/token")
      "https://soracom.zendesk.com/access/jwt?jwt=#{res['token']}&return_to=#{return_to}"
    end

    # SAMユーザー一覧取得
    def list_users()
      @api.get(path: "/operators/#{@auth[:operatorId]}/users")
    end

    # SAMユーザーを削除する
    def delete_user(username)
      @api.delete(path: "/operators/#{@auth[:operatorId]}/users/#{username}")
    end

    # SAMユーザー取得
    def get_user(username=@auth[:userName])
      @api.get(path: "/operators/#{@auth[:operatorId]}/users/#{username}")
    end

    # SAMユーザーを新しく追加する
    def create_user(username, description='')
      @api.post(path: "/operators/#{@auth[:operatorId]}/users/#{username}", payload: { description: description })
    end

    # SAMユーザーを更新する
    def update_user(username, description='')
      @api.put(path: "/operators/#{@auth[:operatorId]}/users/#{username}", payload: { description: description })
    end

    # SAMユーザーのAuthKey一覧取得
    def list_users_auth_key(username=@auth[:userName])
      @api.get(path: "/operators/#{@auth[:operatorId]}/users/#{username}/auth_keys")
    end

    # SAMユーザーのAuthKey生成
    def generate_users_auth_key(username=@auth[:userName])
      @api.post(path: "/operators/#{@auth[:operatorId]}/users/#{username}/auth_keys")
    end

    # SAMユーザーのAuthKey削除
    def delete_users_auth_key(username, auth_key_id)
      @api.delete(path: "/operators/#{@auth[:operatorId]}/users/#{username}/auth_keys/#{auth_key_id}")
    end

    # SAMユーザーのAuthKey取得
    def get_users_auth_key(username, auth_key_id)
      @api.get(path: "/operators/#{@auth[:operatorId]}/users/#{username}/auth_keys/#{auth_key_id}")
    end

    # SAMユーザーのパスワードを削除する
    def delete_user_password(username=@auth[:userName])
      @api.delete(path: "/operators/#{@auth[:operatorId]}/users/#{username}/password")
    end

    # SAMユーザーのパスワードがセットされているかを取得する
    def has_user_password(username=@auth[:userName])
      @api.get(path: "/operators/#{@auth[:operatorId]}/users/#{username}/password")
    end

    # SAMユーザーのパスワードを作成する
    def create_user_password(username=@auth[:userName], password)
      @api.post(path: "/operators/#{@auth[:operatorId]}/users/#{username}/password", payload:{password: password})
    end

    # SAMユーザーの権限設定を取得する
    def get_user_permission(username=@auth[:userName])
      @api.get(path: "/operators/#{@auth[:operatorId]}/users/#{username}/permission")
    end

    # SAMユーザーの権限を更新する
    def update_user_permission(username=@auth[:userName], description, permission)
      @api.put(path: "/operators/#{@auth[:operatorId]}/users/#{username}/permission", payload:{description: description, permission: permission})
    end

    # Role一覧取得
    def list_roles()
      @api.get(path: "/operators/#{@auth[:operatorId]}/roles")
    end

    # Role を削除する
    def delete_role(role_id)
      @api.delete(path: "/operators/#{@auth[:operatorId]}/roles/#{role_id}")
    end

    # Role を取得する
    def get_role(role_id)
      @api.get(path: "/operators/#{@auth[:operatorId]}/roles/#{role_id}")
    end

    # Role を新しく追加する
    def create_role(role_id, description='', permission)
      @api.post(path: "/operators/#{@auth[:operatorId]}/roles/#{role_id}", payload:{description: description, permission: permission})
    end

    # Role を編集する
    def update_role(role_id, description='', permission)
      @api.put(path: "/operators/#{@auth[:operatorId]}/roles/#{role_id}", payload:{description: description, permission: permission})
    end

    # Role に紐づくユーザーの一覧を取得する
    def list_role_attached_users(role_id)
      @api.get(path: "/operators/#{@auth[:operatorId]}/roles/#{role_id}/users")
    end

    # SAMユーザーのロール一覧取得
    def list_user_roles(usre_name)
      @api.get(path: "/operators/#{@auth[:operatorId]}/users/#{user_name}/roles")
    end

    # SAMユーザーにロールをアタッチ
    def attach_role_to_user(user_name)
      @api.post(path: "/operators/#{@auth[:operatorId]}/users/#{user_name}")
    end

    # SAMユーザーからロールをデタッチ
    def delete_role_from_user(user_name, role_id)
      @api.delete(path: "/operators/#{@auth[:operatorId]}/users/#{user_name}/roles/#{role_id}")
    end

    # OperatorのAuthKey一覧取得
    def list_operator_auth_keys()
      @api.get(path: "/operators/#{@auth[:operatorId]}/auth_keys")
    end

    # OperatorのAuthKey生成
    def generate_operator_auth_key()
      @api.post(path: "/operators/#{@auth[:operatorId]}/auth_keys")
    end

    # OperatorのAuthKey削除
    def delete_operator_auth_key(auth_key_id)
      @api.delete(path: "/operators/#{@auth[:operatorId]}/auth_keys/#{auth_key_id}")
    end

    # APIキーを取得
    def api_key
      @auth[:apiKey]
    end

    # オペレータIDを取得
    def operator_id
      @auth[:operatorId]
    end

    # ユーザ名を取得
    def user_name
      @auth[:userName]
    end

    # トークンを取得
    def token
      @auth[:token]
    end

    private

    # authenticate by email and password
    def auth(email, password, endpoint)
      endpoint = API_BASE_URL if endpoint.nil?
      res = RestClient.post endpoint + '/auth',
                            { email: email, password: password },
                            'Content-Type' => 'application/json',
                            'Accept' => 'application/json'
      result = JSON.parse(res.body)
      fail result['message'] if res.code != '200'
      Hash[JSON.parse(res.body).map { |k, v| [k.to_sym, v] }]
    end

    # authenticate by email and password
    def auth_by_key(auth_key_id, auth_key, endpoint)
      endpoint = API_BASE_URL if endpoint.nil?
      res = RestClient.post endpoint + '/auth',
                            { authKeyId: auth_key_id, authKey: auth_key },
                            'Content-Type' => 'application/json',
                            'Accept' => 'application/json'
      result = JSON.parse(res.body)
      fail result['message'] if res.code != '200'
      Hash[JSON.parse(res.body).map { |k, v| [k.to_sym, v] }]
    end

    def extract_jwt(jwt)
      encoded = jwt.split('.')[1]
      encoded += '=' * (4 - encoded.length % 4) # add padding(=) for Base64
      Base64.decode64(encoded)
    end

    def transform_json(json)
      begin
        target=JSON.parse(json)
        if target.class == Hash
          target = target.map{|k,v| {"key" => k, "value" => v}}
        end
      rescue JSON::ParserError
        abort("ERROR: parameter cannot be parsed as JSON.")
      end
      JSON.pretty_generate target
    end
  end
end
