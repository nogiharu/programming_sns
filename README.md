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