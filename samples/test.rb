#!/usr/bin/env ruby
require 'soracom'

# SORACOM APIアクセス用クライアントの初期化方法
# 1. client = Soracom::Client.new(email: '登録メールアドレス', password: 'パスワード')
# 2. client = Soracom::Client.new
#   (環境変数 SORACOM_EMAIL & SORACOM_PASSWORD を参照)

client = Soracom::Client.new

# サブスクライバー(SIM)の一覧を取得
sims = client.list_subscribers

puts "found #{sims.count} SIMs."

# 操作対象のIMSI配列を用意
imsis = sims.map { |sim| sim['imsi'] }

puts 'change plan to s1.fast'

# プラン変更のためのAPIをコールする
client.update_subscriber_speed_class(imsis, 's1.fast')

puts 'done'
