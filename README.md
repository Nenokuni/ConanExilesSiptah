# 概要

ConanExiles Dedicated serverを自動で建てるDockerコンテナ。

# コンテナの構築から起動まで

必要要件
| アプリケーション | バージョン                |
| :--------------- | :------------------------ |
| docker           | `19.03.8`                 |
| docker-compose   | `1.25.4`                  |

リポジトリをクローン。
```
git clone https://github.com/sevenspice/ConanExiles.git
```

ディレクトリ移動。
```
cd ConanExiles
```

docker-compose.ymlの作成。
```
cp docker-compose.origin.yml docker-compose.yml
```

docker-compose.ymlの編集。
```
vi docker-compose.yml
```
* environment の箇所を適切に編集すること。

コンテナの構築・生成・起動。
```
docker-compose up -d --build
```

初回起動時はクライアントのサーバー一覧に表示されるまでにかなりの時間を要する。進捗を知りたいなら以下の方法でログを確認する。
```
docker exec -it conan /bin/bash
screen -r conan
```
* `ctl+a,ctl+d`で抜け出せる。

## 備考

基本的にはコンテナが立ち上がると同時にゲームサーバーも自動で起動する。手動で起動する場合はdocker-compose.ymlを以下のように修正すること。
```
command: bash -c '/entrypoint.sh && /start.sh && /bin/bash'
↓
command: bash -c '/entrypoint.sh && /bin/bash'
```

# ゲームサーバー起動方法

コンテナにログイン。
```
docker exec -it conan /bin/bash
```

サーバー起動。
```
/start.sh
```

起動を確認する。
```
screen -ls
screen -r conan
```

デタッチする。
```
ctl-A ctl-d
```

ログアウト。
```
exit
```

## コンテナにログインせずに起動する

```
docker exec -it conan sh -c "exec >/dev/tty 2>/dev/tty </dev/tty && /start.sh"
```

## コンテナにログインせずにログをtailする

```
docker exec -it conan sh -c "tail -f /conan/server/ConanSandbox/Saved/Logs/ConanSandbox.log"
```

# ゲームデータの保存先

ゲームサーバーデータ。
```
/conan/server/ConanSandbox/Saved
```

キャッシュデータ。
```
/root
```

ボリューム。
```
conan_exiles
conan_exiles-wine
```
* ゲームデータをバックアップするのであれば上記ボリュームをバックアップすればよい。

# ゲームサーバー通常再起動手順

* サーバーメッセージや管理者パスワード・サーバー設定を変更した場合はこの手順で再起動すると反映される。

コンテナ停止。
```
docker-compose down
```

コンテナ起動。
```
docker-compose up -d --build
```

コンテナにログイン。
```
docker exec -it conan /bin/bash
```

サーバー起動。
```
/start.sh
```

起動を確認する。
```
screen -ls
screen -r conan
```

デタッチする。
```
ctl-A ctl-d
```

ログアウト。
```
exit
```

# ゲームサーバーアップデート手順

* ゲームサーバーのアップデートだけならばイメージを作り直す必要はない。
* 下記手順でゲームサーバーのアップデートは行える。

コンテナにログイン。
```
docker exec -it conan /bin/bash
```

サーバーを停止。
```
/kill.sh
```

アップデート。
```
/update.sh
```

サーバーを起動。
```
/start.sh
```

ログアウト。
```
exit
```

コンテナを削除するとサーバのアップデートデータも消えてしまうため、アップデートを永続化したいのであれば[コンテナフルアップデート手順](#コンテナフルアップデート手順)を実行すること。

# コンテナフルアップデート手順

* コンテナイメージそのものに変更を加えた場合はイメージを作り直す必要がある。
* ボリュームデータのバックアップとリストアを行わなければ以前の状態を保持できないため注意すること。

ボリュームデータのバックアップ。
```
docker run --rm --volumes-from conan -v conan-saved:/backup busybox tar cvf /backup/backup.tar /conan/server/ConanSandbox/Saved
docker run --rm --volumes-from conan -v conan-saved-wine:/backup busybox tar cvf /backup/backup.tar /home/conan
```

コンテナとボリュームの削除。
```
docker-compose down -v
```

イメージを削除する。
```
docker rmi conan:latest
```

イメージの再構築からコンテナの構築・起動。
```
docker-compose up -d --build
```

ボリュームデータのリストア。
```
docker run --rm --volumes-from conan -v conan-saved:/backup busybox tar xvf /backup/backup.tar
docker run --rm --volumes-from conan -v conan-saved-wine:/backup busybox tar xvf /backup/backup.tar
```

# キャラクターデータはそのままで初期化する

マップが無茶苦茶になったりした場合に有効。キャラクターデータのみ保持で他すべて初期化される。

コンテナにログインする。
```
docker exec -it conan /bin/bash
```

ディレクトリを移動する。
```
cd /conan/server/ConanSandbox/Saved
```

初期化する。
```
wine start.exe Z:\\conan\\server\\ConanSandbox\\Saved\\ServerCleanup.bat
```

# RCONを使ったブロードキャストメッセージの送信

サーバー内でプレイ中のプレイヤーにメッセージを伝える方法を紹介する。

RCONをダウンロードする。
```
wget https://github.com/Tiiffi/mcrcon/releases/download/v0.7.1/mcrcon-0.7.1-linux-x86-64.tar.gz
```

解凍する。
```
tar xvfz https://github.com/Tiiffi/mcrcon/releases/download/v0.7.1/mcrcon-0.7.1-linux-x86-64.tar.gz
```

ディレクトリを移動する。
```
cd mcrcon-0.7.1-linux-x86-64
```

ブロードキャストメッセージの送信。
```
./mcrcon -H localhost -P 25575 -p <設定したRCONのパスワード> -s "broadcast <送信したいメッセージ>"
```
* サーバー内でプレイしていると画面にメッセージボックスが表示されるはずである。

# 注意点

Conan Exilesはマシンスペックを非常に要求する。Doker for WindowsあるいはDocker for Macのデフォルト設定だとゲームサーバーの起動は失敗するため以下の様に設定を変更すること。

* Dockerコンテナのディスクスペースサイズを30G以上に拡張する必要あり。
* Dockerコンテナの使用可能メモリを8G以上に拡張する必要あり。
* 当然だがコンテナを稼働させるホストマシンは上記ディスクスペースサイズ・メモリ容量以上のディスク空き容量・メモリ容量が必要である。
