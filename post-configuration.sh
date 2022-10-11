#!/bin/bash

touch /etc/apt/apt.conf.d/99verify-peer.conf \
&& echo >>/etc/apt/apt.conf.d/99verify-peer.conf "Aquire { https::Verify-Peer false }"

##
## Install gpg keye for apt
##

echo ""
echo "Installing latest cf-cli"
wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
echo "deb https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list

. /etc/os-release
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key | apt-key add -

##
## Install generic ubuntu packages
##

apt update
apt install -y utils mysql-client mysql-common perl perl-base perl-modules postgresql-client python-pip python2-dev redis-tools sensible-utils sshpass ruby-dev gpg dnsutils gettext-base bind9utils puthon3-pip nmap

##
## Install cf8 and skopeo
##

apt install -y cf8-cli
apt install -y skopeo
apt clean

##
## Install mc
##

echo ""
echo "Installing latest mc"

wget --no-check-certificate -q -O /usr/bin/mc https://dl.minio.io/client/mc/release/linux-amd64/mc
chmod 755 /usr/bin/mc

##
## Install bosh
##

echo ""

# Cut the v off this VER and manually add it where needed as the VER in the path has the v but not the VER in the filename
VER=$( curl --insecure -Ls -o /dev/null -w %{url_effective} https://github.com/cloudfoundry/bosh-cli/releases/latest | awk -F / '{ print $NF }' | cut -c 2- )
echo "Installing latest bosh version ($VER) as bosh"

curl --insecure -Ls -o /usr/bin/bosh https://github.com/cloudfoundry/bosh-cli/releases/download/v${VER}/bosh-cli-${VER}-linux-amd64
chmod 755 /usr/bin/bosh

##
## Install govc
##

echo ""
VER=$( curl --insecure -Ls -o /dev/null -w %{url_effective} https://github.com/vmware/govmomi/releases/latest | awk -F / '{ print $NF }' )
echo "Installing govc (${VER}) as /usr/bin/govc" 

curl --insecure -Ls -o ./govc.tar.gz https://github.com/vmware/govmomi/releases/download/${VER}/govc_Linux_x86_64.tar.gz

tar xvzf govc.tar.gz
chmod 755 govc
mv govc /usr/bin/govc

##
## Install om-linux
##

echo ""
VER=$( curl --insecure -Ls -o /dev/null -w %{url_effective} https://github.com/pivotal-cf/om/releases/latest | awk -F / '{ print $NF }' )
echo "Installing om-linux (${VER}) as /usr/bin/om-linux"

curl --insecure -Ls -o /usr/bin/om-linux https://github.com/pivotal-cf/om/releases/download/${VER}/om-linux-${VER}
chmod 755 /usr/bin/om-linux

#
## Install jq
# 

echo ""
VER=$( curl --insecure -Ls -o /dev/null -w %{url_effective} https://github.com/stedolan/jq/releases/latest | awk -F / '{ print $NF }' )
echo "Installing latest jq (${VER})as jq"

curl --insecure -Ls -o /usr/bin/jq https://github.com/stedolan/jq/releases/download/${VER}/jq-linux64
chmod 755 /usr/bin/jq

#
## Install yq 4
#

echo ""
VER=$( curl --insecure -Ls -o /dev/null -w %{url_effective} https://github.com/mikefarah/yq/releases/latest | awk -F / '{ print $NF }' )
echo "Installing yq-${VER}"
echo

curl --insecure -Ls -o /usr/bin/yq4 https://github.com/mikefarah/yq/releases/download/${VER}/yq_linux_amd64
chmod 755 /usr/bin/yq4

#
## Install yq 3.4.1 
#

echo ""
VER="3.4.1"
echo "Installing yq-${VER}"
echo

curl --insecure -Ls -o /usr/bin/yq https://github.com/mikefarah/yq/releases/download/${VER}/yq_linux_amd64
chmod 755 /usr/bin/yq
ln -s /usr/bin/yq /usr/bin/yq3

#
## Looks like the uaac client was removed - add it back in as we use it
#

echo ""
echo "Installing uaac via gem"

echo ":ssl_verify_mode: 0" > ~/.gemrc

gem install cf-uaac

#
## Install jfrog cli
#

echo ""
echo "Installing jfrog cli"

curl --insecure -fL https://getcli.jfrog.io | sh
mv jfrog /usr/bin/jfrog
chmod uog+rx /usr/bin/jfrog

#
### Install credhub-cli
#

echo ""
VER=$( curl --insecure -Ls -o /dev/null -w %{url_effective} https://github.com/cloudfoundry-incubator/credhub-cli/releases/latest | awk -F / '{ print $NF }' )
echo "Installing latest credhub-cli ${VER}"

curl --insecure -s -Lo ./credhub.tar.gz https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${VER}/credhub-linux-${VER}.tgz
tar xvzf credhub.tar.gz 
mv credhub /usr/bin/credhub
chmod 755 /usr/bin/credhub

#
### Install ytt
#

echo ""
VER=$( curl --insecure -Ls -o /dev/null -w %{url_effective} https://github.com/k14s/ytt/releases/latest | awk -F / '{ print $NF }' )
echo "Installing latest ytt (${VER}"

curl --insecure -s -Lo /usr/bin/ytt https://github.com/k14s/ytt/releases/download/${VER}/ytt-linux-amd64
chmod 755 /usr/bin/ytt

#
### Install kapp
#

echo ""
VER=$( curl --insecure -Ls -o /dev/null -w %{url_effective} https://github.com/k14s/kapp/releases/latest | awk -F / '{ print $NF }' )
echo "Installing latest kapp (${VER}"

curl --insecure -s -Lo /usr/bin/kapp https://github.com/k14s/kapp/releases/download/${VER}/kapp-linux-amd64
chmod 755 /usr/bin/kapp

#
### Install hub
#

echo ""
VER=$( curl --insecure -Ls -o /dev/null -w %{url_effective} https://github.com/github/hub/releases/latest | awk -F / '{ print $NF }' | cut -c 2- )
echo "Installing latest hub (${VER})"
 
curl --insecure -s -Lo hub.tar.gz https://github.com/github/hub/releases/download/v${VER}/hub-linux-amd64-${VER}.tgz
tar xvzf hub.tar.gz
cp hub-linux-amd64-${VER}/bin/hub /usr/bin/hub
chmod 755 /usr/bin/hub

