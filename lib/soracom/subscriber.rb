module Soracom
  # Subscriber = SIM Class
  class Subscriber < OpenStruct
    def initialize(hash, client)
      super(hash)
      @client = client
    end

    def activate
      @client.activate_subscriber([imsi])
    end

    def deactivate
      @client.deactivate_subscriber([imsi])
    end
  end
end
