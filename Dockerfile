FROM ruby:2.6-stretch

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

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
    openjdk-8-jdk \
    unzip \
    wget

# Install Chrome so we can run system specs
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable

# install FITS for file characterization
RUN mkdir -p /opt/fits && \
  curl -fSL -o /opt/fits-1.0.5.zip http://projects.iq.harvard.edu/files/fits/files/fits-1.0.5.zip && \
  cd /opt && unzip fits-1.0.5.zip && chmod +X fits-1.0.5/fits.sh

RUN gem update --system
RUN gem install bundler:2.1.4

RUN mkdir /data
WORKDIR /data

ADD Gemfile /data
ADD Gemfile.lock /data

RUN bundle install --jobs "$(nproc)" --verbose

ADD . /data
RUN bundle install
RUN bundle exec rake assets:precompile

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:3000"]
ENTRYPOINT ["/bin/sh", "/data/bin/docker-entrypoint.sh"]
