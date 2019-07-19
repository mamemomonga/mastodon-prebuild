# /home/mastodon を早いマシンでつくるやつ

です。クライアントは Ubuntu 18.04 向けです。

# 使用方法

	$ sudo apt install -y curl make git
	$ curl https://get.docker.com/ | sh
	$ sudo sh -c 'usermod -a -G docker $SUDO_USER'
	$ exec $SHELL
	$ git clone https://github.com/mamemomonga/mastodon-prebuild.git
	$ cd mastodon-prebuild
	$ make

mastodon.tar.xz ができるので、それをコピーして /home/mastodon に展開すればできあがり
