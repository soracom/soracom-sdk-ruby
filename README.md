# SORACOM SDK for Ruby
SORACOM SDK for Ruby は、株式会社 SORACOM の提供する IoT プラットフォームの API を Ruby プログラムからコールするためのライブラリとなります。  
またコマンドラインインターフェース(CLI)も付属していますので、プログラムを組まなくてもシェルスクリプト等から API を呼び出す事が可能となります。

## インストール

```
$ (sudo) gem install soracom # 環境により sudo が必要となる場合があります
```

としてインストールする事で、ライブラリおよびコマンドラインインターフェース ( soracom コマンド)が導入されます。

## 使用方法

### SDK

#### 使用例
サンプルコード: SIMの一覧を取得し、プランを s1.fast に変更する
```ruby
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

```

### コマンドラインインターフェース
#### 認証情報の設定
環境変数にメールアドレス・パスワードを設定します。
```
$ export SORACOM_EMAIL='somebody@example.com'
$ export SORACOM_PASSWORD='mypassword'
```

認証情報が正しく設定されているかどうかを確認するには、**soracom auth** コマンドを使用します。
```
~$ soracom auth
testing authentication...
authentication succeeded.
apiKey: APIキー
operatorId: OPで始まるオペレータID
```

#### 使用例
SIMの一覧を取得する
```
$ soracom subscriber list
[
  {
    (SIMの情報)
  },
  :
  {
    (SIMの情報)
  }
]
```

出力されたJSONフォーマットのデータから特定のパラメータを抜き出すには、**jq** コマンドが有用です。
```
$ soracom subscriber list | jq -r '.[].imsi' | tee imsi.txt
001010000000000
001010000000001
001010000000002
      :
```

複数のSIMに対して、プランを s1.fast に変更する
```
$ soracom subscriber update_speed_class --imsi $(cat imsi.txt) --speed-class s1.fast
[
  {
    (変更後のSIMの情報)
  },
  :
  {
    (変更後のSIMの情報)
  }
]
```

#### コマンドライン補完
利用しているシェルが bash/zsh であれば、
```
eval "$(soracom complete)"
```
と .bashrc や　.zshrc などに書く事で、soracom コマンドのコマンド名補完が可能です。

```
$ soracom [tab]
~$ soracom
auth           stats
event_handler  subscriber
group          support
sim            version

$ soracom sub[tab]

$ soracom subscriber [tab]
activate
deactivate
delete_tag
disable_termination
enable_termination
help
list
register
set_expiry_time
set_group
terminate
unset_expiry_time
unset_group
update_speed_class
update_tags

$ soracom subscriber li[tab]
$ soracom subscriber list
```
