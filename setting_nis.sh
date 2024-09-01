#!/bin/bash

# エラー時にスクリプトを終了
set -e

# 必要なパッケージのインストール
sudo dnf install -y git curl rpm-build dnf-plugins-core

# ypbind-mt リポジトリのクローンとチェックアウト
git clone https://github.com/thkukuk/ypbind-mt
cd ypbind-mt
git checkout v2.7.2
cd ..

# tar.gz の作成
tar --exclude-vcs --transform 's/ypbind-mt/ypbind-mt-2.7.2/' -cvzf ypbind-mt-2.7.2.tar.gz ypbind-mt

# ypbind のソース RPM のダウンロードとインストール
curl -O http://dl.rockylinux.org/pub/rocky/8/AppStream/source/tree/Packages/y/ypbind-2.5-2.el8.src.rpm
rpm -Uvh ypbind-2.5-2.el8.src.rpm

# SPEC ファイルの修正
sed -i.orig -e 's/Version: 2.5/Version: 2.7.2/' -e 's/%patch4 -b .gettext_version/#%patch4 -b .gettext_version/' rpmbuild/SPECS/ypbind.spec

# 必要な依存パッケージのインストール
sudo dnf --enablerepo=devel install -y dbus-glib-devel libnsl2-devel libtirpc-devel systemd-devel

# ソースファイルのコピー
cp ypbind-mt-2.7.2.tar.gz rpmbuild/SOURCES/

# ypbind の RPM のビルド
rpmbuild -bb rpmbuild/SPECS/ypbind.spec

# libnss_nis リポジトリのクローンとチェックアウト
git clone https://github.com/thkukuk/libnss_nis
cd libnss_nis
git checkout v3.2
cd ..

# tar.gz の作成
tar --exclude-vcs --transform 's/libnss_nis/libnss_nis-3.2/' -cvzf libnss_nis-3.2.tar.gz libnss_nis

# nss_nis のソース RPM のダウンロードとインストール
curl -O http://dl.rockylinux.org/pub/rocky/8/BaseOS/source/tree/Packages/n/nss_nis-3.0-8.el8.src.rpm
rpm -Uvh nss_nis-3.0-8.el8.src.rpm

# nss_nis の SPEC ファイルの修正
sed -i.orig -e 's/Version:        3.0/Version:        3.2/' \
-e 's|Source:         https://github.com/thkukuk/libnss_nis/archive/v%{version}.tar.gz|Source:         https://github.com/thkukuk/libnss_nis/archive/libnss_nis-%{version}.tar.gz|' \
rpmbuild/SPECS/nss_nis.spec

# ソースファイルのコピー
cp libnss_nis-3.2.tar.gz rpmbuild/SOURCES/

# nss_nis の RPM のビルド
rpmbuild -bb rpmbuild/SPECS/nss_nis.spec

# yp-tools のソース RPM のダウンロード
curl -O http://dl.rockylinux.org/pub/rocky/8/AppStream/source/tree/Packages/y/yp-tools-4.2.3-2.el8.src.rpm

# yp-tools の RPM のリビルド
rpmbuild --rebuild yp-tools-4.2.3-2.el8.src.rpm

# すべてのパッケージをインストール
sudo dnf localinstall -y rpmbuild/RPMS/x86_64/ypbind-2.7.2-2.el9.x86_64.rpm \
                      rpmbuild/RPMS/x86_64/nss_nis-3.2-8.el9.x86_64.rpm  \
                      rpmbuild/RPMS/x86_64/yp-tools-4.2.3-2.el9.x86_64.rpm

echo "すべての操作が完了しました！"
