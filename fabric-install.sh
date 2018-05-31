#!/bin/sh
# by xx

#===============安装环境===============#
# 1.检查Docker是否安装
# https://store.docker.com/editions/community/docker-ce-desktop-mac

which "docker" >/dev/null
if [ $? -ne 0 ]; then
	#Docker下载地址https://store.docker.com/editions/community/docker-ce-desktop-mac
	#设置国内镜像https://registry.docker-cn.com
	echo "请先安装Docker"
	exit 1
fi

# 2.检查Go是否安装
which "go" >/dev/null
if [ $? -ne 0 ]; then
	# 安装Go,默认安装到/usr/local/Cellar/go/x.xx.x
	brew install go
	# 设置Go环境变量
	echo "# Go" >>~/.bash_profile
	echo "export GOPATH=\$HOME/Desktop/go" >>~/.bash_profile
	# echo "export GOROOT=/usr/local/Cellar/go" >>.bash_profile
	echo "export GOBIN=\$GOPAHT/bin" >>~/.bash_profile
	echo "export PATH=\$PATH:\$GOPATH:\$GOBIN" >>~/.bash_profile
	source ~/.bash_profile
fi

# 3.检查Node是否安装
which "node" >/dev/null
if [ $? -ne 0 ]; then
	# 安装nvm,在https://github.com/creationix/nvm#install-script中查看最新版本
	curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
	echo "# nvm" >>~/.bash_profile
	echo "export NVM_DIR=\"\$HOME/.nvm\"" >>~/.bash_profile
	echo "[ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"" >>.bash_profile
	source ~/.bash_profile

	# 通过nvm安装node
	# Node.js version 9.x is not supported at this time.
	# version 8.9.x or greater
	nvm install 8.11.2
	# 更新npm
	npm i -g npm
	nvm use 8.11.2
fi

#===============安装Hyperleder fabric===============#
cd ~/Desktop
mkdir -p go/src/github.com/hyperledger
cd go/src/github.com/hyperledger
#下载fabric
git clone https://github.com/hyperledger/fabric.git
git checkout v1.1.0
#安装镜像
cd fabric/scripts
bash bootstrap.sh
cp -rf bin/ ./../examples/
cd ./../examples/e2e_cli/

# docker-compose是1.21版本会出现network e2ecli_default not found
# 解决办法是 将e2e_cli/base目录下的peer-base.yaml里网络名改成如下名称即可
#- CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=e2e_cli_default
if [[ $(docker-compose -v) =~ "1.21" ]]; then
	#mac 下-i后要加上 ""
	sed -i "" 's/e2ecli_default/e2e_cli_default/' base/peer-base.yaml
fi

#清理容器
docker rm -f $(docker ps -aq)
#启动Hyperledger网络环境测试本地部署是否正确
./network_setup.sh up
