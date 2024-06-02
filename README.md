# programming_sns

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


flutter pub run flutter_native_splash:create

## XMLHttpRequest error が発生したときの対処法
rm /opt/homebrew/Caskroom/flutter/3.10.5/flutter/bin/cache/flutter_tools.stamp 

/opt/homebrew/Caskroom/flutter/3.13.0/flutter/packages/flutter_tools/lib/src/web/chrome.dart 
##

      '--disable-background-timer-throttling',
      // Since we are using a temp profile, disable features that slow the
      // Chrome launch.
      '--disable-extensions',
      '--disable-web-security', // 追加
      '--disable-popup-blocking',
      '--bwsi',
      '--no-first-run',
      '--no-default-browser-check',
      '--disable-default-apps',
      '--disable-translate',

##

## docker INSTALL
docker run -it --rm \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --volume "$(pwd)"/appwrite:/usr/src/code/appwrite:rw \
    --entrypoint="install" \
    appwrite/appwrite:1.4.5

## docker UPGRADE
docker run -it --rm \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --volume "$(pwd)"/appwrite:/usr/src/code/appwrite:rw \
    --entrypoint="upgrade" \
    appwrite/appwrite:1.5.3

上やった後に下やる！
 
cd appwrite/
docker compose exec appwrite migrate


# WebServer
flutter run -d web-server --web-hostname=0.0.0.0 --web-port=1121

flutter run -d web-server --web-port=1121

flutter run -d web-server  --web-port=1121 --web-renderer=html

flutter run -d web-server  --web-port=1121 --web-renderer=html --web-browser-flag --disable-web-security

flutter run -d web-server  --web-port=1127 --web-renderer=html --dart-define env=.env

# cache
flutter pub cache repair

# fvm
fvm releases                             

fvm list    

fvm use 3.16.9 


# サブモジュール
git submodule add https://github.com/nogiharu/flutter_chatview.git
git submodule update --init --recursive
git submodule update --remote

# Supabase
すべてのサービスを停止し、ローカル データベースをリセットするために使用します。

         API URL: http://127.0.0.1:54321
     GraphQL URL: http://127.0.0.1:54321/graphql/v1
  S3 Storage URL: http://127.0.0.1:54321/storage/v1/s3
          DB URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
      Studio URL: http://127.0.0.1:54323
    Inbucket URL: http://127.0.0.1:54324
      JWT secret: super-secret-jwt-token-with-at-least-32-characters-long
        anon key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU
   S3 Access Key: 625729a08b95bf1b7ff351a663f3a23c
   S3 Secret Key: 850181e4652dd023b7a98c58ae0d2d34bd487ee0cc3254aed6eda37307425907
       S3 Region: local



# ローカル、サーバー問わず、Supabaseのダッシュボードからテーブルに変更を加えた時 現在のDBの状態(＝スキーマ)と、マイグレーションファイル に記録されているスキーマとの差分を取ります。

supabase db diff -f 接尾辞

※通常は-f フラグを使用して接尾辞を追加してマイグレーションファイルに出力します。

↓サーバー(＝リンク先のプロジェクト)に対しての、ローカルのマイグレーションファイルに記録されているスキーマとの差分を取ります。

supabase db diff --linked -f 接尾辞

# サーバーと接続確認
supabase migration list

# サーバーとリンク
supabase link --project-ref uttwrhmwyiunhptzxaag

# サーバーと繋がっているかの確認
supabase projects list

supabase stop --no-backup

# サーバーとの同期　 作成したマイグレーションファイルをローカルに適用
supabase migration up
supabase db pull 

# authスキーマ
supabase db pull --schema auth,storage
# ストレージとの同期
supabase db pull --schema storage

# マイグレーションファイルをローカルに反映（データの削除）
supabase db reset 

# サーバーにプッシュ
supabase db push

# マイグレーションファイルを一つにまとめる
supabase migration squash --local

supabase db pull 

上記実行後、以下エラーが出るため、以下実行
supabase migration repair --status reverted 日付
supabase migration repair --status reverted 日付

以下確認
supabase migration list

# マイグレーションファイルを作成
supabase migration new ファイル名



# マイグレーションUPでローカルだけに適用した情報を消したい場合
作成したマイグレーションファイルを消すだけ

# ローカルの差分をマイグレーションファイルで出力
supabase db diff -f ファイル名



# CASCADEつけて
DROP FUNCTION IF EXISTS "public"."handle_new_user" () CASCADE;








