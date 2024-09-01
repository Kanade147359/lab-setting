#!/bin/bash

# エラー時にスクリプトを終了
set -e

# 必要なパッケージのインストール
sudo dnf install -y git curl rpm-build dnf-plugins-core

# authselect のソース RPM のダウンロードとインストール
curl -O http://dl.rockylinux.org/pub/rocky/9/BaseOS/source/tree/Packages/a/authselect-1.2.6-1.el9.src.rpm
rpm -Uvh authselect-1.2.6-1.el9.src.rpm

# SPECファイルの修正
sed -i.orig -e 's/Patch0904:  0904-rhel9-remove-nis-support.patch/#Patch0904:  0904-rhel9-remove-nis-support.patch/' \
-e '/%dir %{_datadir}\/authselect\/default\/minimal\//a %dir %{_datadir}/authselect/default/nis/' \
-e '/%{_datadir}\/authselect\/default\/minimal\/system-auth/a %{_datadir}/authselect/default/nis/dconf-db\n%{_datadir}/authselect/default/nis/dconf-locks\n%{_datadir}/authselect/default/nis/fingerprint-auth\n%{_datadir}/authselect/default/nis/nsswitch.conf\n%{_datadir}/authselect/default/nis/password-auth\n%{_datadir}/authselect/default/nis/postlogin\n%{_datadir}/authselect/default/nis/README\n%{_datadir}/authselect/default/nis/REQUIREMENTS\n%{_datadir}/authselect/default/nis/smartcard-auth\n%{_datadir}/authselect/default/nis/system-auth' \
rpmbuild/SPECS/authselect.spec

# 必要な依存パッケージのインストール
sudo dnf --enablerepo=devel install -y libcmocka-devel popt-devel po4a python3-devel

# authselect の RPM のビルド
rpmbuild -bb rpmbuild/SPECS/authselect.spec

# authselect-libs の再インストール
sudo dnf reinstall -y rpmbuild/RPMS/x86_64/authselect-libs-1.2.6-2.el9.x86_64.rpm

# authselect で NIS プロファイルを選択
authselect select nis --force

# autofs のソース RPM のダウンロードとインストール
curl -O http://dl.rockylinux.org/pub/rocky/9/devel/source/tree/Packages/a/autofs-5.1.7-58.el9.src.rpm
rpm -Uvh autofs-5.1.7-58.el9.src.rpm

# 必要な依存パッケージのインストール
sudo dnf install -y cyrus-sasl-devel krb5-devel libsss_autofs libxml2-devel openldap-devel

# autofs の RPM のビルド
rpmbuild -bb rpmbuild/SPECS/autofs.spec

# nfs-utils のインストール
sudo dnf install -y nfs-utils

# autofs の RPM のインストール
sudo dnf localinstall -y rpmbuild/RPMS/x86_64/autofs-5.1.7-58.el9.x86_64.rpm

echo "すべての操作が完了しました！"
