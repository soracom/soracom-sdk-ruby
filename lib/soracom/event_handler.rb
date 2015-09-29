module Soracom
  # EventHandlerクラス
  # 初期化方法1. 新規に作成
  # 初期化方法2. 特定ハンドラのIDを指定して初期化({handlerId:HANDLERID}) → APIで現時点の内容を取得
  # 初期化方法3. hashを指定して初期化(list_event_handlersの戻り値を利用など)
  class EventHandler < OpenStruct
    def initialize(hash = {}, client = Soracom::Client.new)
      @log = Logger.new(STDERR)
      @log.level = ENV['SORACOM_DEBUG'] ? Logger::DEBUG : Logger::WARN
      if hash.keys.length == 0 # 新規作成
        hash = Hash[%w(handlerId targetImsi targetOperatorId targetTag name description ruleConfig actionConfigList).map { |k| [k, nil] }]
      end
      if hash.keys.length == 1 && hash.keys[0] == 'handlerId' # IDのみを指定して作成
        hash = client.list_event_handlers(handler_id: hash['handlerId'])[0]
      end
      super(hash)
      @client = client
    end

    # 新規作成または更新用のpayloadをJSON形式で取得
    def to_json
      to_h.select { |k, v| true if !v.nil? && k != :handlerId }.to_json
    end

    # 現在の内容でEventHandlerを作成または更新
    def save
      result = validate
      fail result unless result == true
      @log.debug(to_json)
      if handlerId
        @client.update_event_handler(handlerId, to_json)
      else
        @client.create_event_handler(to_json)
      end
    end

    def validate
      return 'No target is defined' if [targetImsi, targetOperatorId, targetTag].compact.length == 0
      return 'No rule is defined' if ruleConfig.nil? || ruleConfig.length == 0
      return 'No action is defined' if actionConfigList.nil? || actionConfigList.length == 0
      true
    end
  end
end
