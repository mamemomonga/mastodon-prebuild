FROM ubuntu:18.04

RUN set -xe && \
	rm -f /etc/localtime && \
	ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
	echo 'Asia/Tokyo' > /etc/timezone

RUN set -xe && \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		curl ca-certificates gnupg  apt-transport-https && \
	curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
	curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg > /tmp/pubkey.gpg && \
	apt-key add /tmp/pubkey.gpg && \
	rm /tmp/pubkey.gpg && \
	echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		yarn nodejs \
		git-core locales vim sudo screen make man \
		build-essential gnupg ca-certificates \
		imagemagick ffmpeg libpq-dev libxml2-dev libxslt1-dev file git-core \
		g++ libprotobuf-dev protobuf-compiler pkg-config gcc autoconf \
		bison build-essential libssl-dev libyaml-dev libreadline6-dev \
		zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev \
		nginx redis-server redis-tools postgresql postgresql-contrib \
		libidn11-dev libicu-dev libjemalloc-dev && \
 	rm -rf /var/lib/apt/lists/*

RUN set -xe && \
	mkdir /opt/skel && \
	useradd -m -s /bin/bash -u 10000 mastodon

USER mastodon
RUN set -xe && \
	cd && \
	git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
	cd ~/.rbenv && src/configure && make -C src && \
	echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc && \
	echo 'eval "$(rbenv init -)"' >> ~/.bashrc && \
	export PATH="$HOME/.rbenv/bin:$PATH" && \
	eval "$(rbenv init -)" && \
	git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build && \
	RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install 2.6.1 && \
	rbenv global 2.6.1 && \
	gem update --system && \
	gem install bundler --no-document --force

RUN set -xe && \
	export PATH="$HOME/.rbenv/bin:$PATH" && \
	eval "$(rbenv init -)" && \
	cd && \
	git clone https://github.com/tootsuite/mastodon.git live && cd live && \
	git checkout $(git tag -l | grep -v 'rc[0-9]*$' | sort -V | tail -n 1) && \
	bundle install -j$(getconf _NPROCESSORS_ONLN) --deployment --without development test && \
	yarn install --pure-lockfile

ENV RAILS_ENV="production"
ENV NODE_ENV="production"

RUN set -xe && \
	export PATH="$HOME/.rbenv/bin:$PATH" && \
	eval "$(rbenv init -)" && \
	cd /home/mastodon/live && \
	OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder bundle exec rails assets:precompile && \
	yarn cache clean

USER root

