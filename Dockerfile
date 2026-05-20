FROM ruby:3.2.4

RUN curl -sL https://deb.nodesource.com/setup_24.x | bash -

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    imagemagick \
    libpq-dev \
    libsqlite3-dev \
    libxml2-dev \
    libxslt-dev \
    netcat-openbsd \
    nodejs \
    openjdk-17-jre-headless \
    unzip \
    wget

# Install Chrome so we can run system specs
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable

# install FITS for file characterization
RUN mkdir -p /opt/fits && \
  curl -fSL -o /opt/fits/fits-1.5.5.zip https://github.com/harvard-lts/fits/releases/download/1.5.5/fits-1.5.5.zip && \
  cd /opt/fits && unzip fits-1.5.5.zip && chmod +X /opt/fits/fits.sh && \
  ln -s /opt/fits/fits.sh /usr/local/bin/fits

RUN gem update --system 4.0.9
RUN gem install bundler:2.7.2

RUN mkdir /data
WORKDIR /data

ADD Gemfile /data
ADD Gemfile.lock /data

RUN bundle install --jobs "$(nproc)" --verbose

ADD . /data
RUN bundle install
#RUN bundle exec rake assets:precompile

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:3000"]
ENTRYPOINT ["/bin/sh", "/data/bin/docker-entrypoint.sh"]
