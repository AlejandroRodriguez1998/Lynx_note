FROM ruby:3.0.2-slim
RUN printf 'deb https://deb.debian.org/debian bullseye main\n' > /etc/apt/sources.list \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get update -qq && apt-get install -y --no-install-recommends build-essential libsqlite3-dev ca-certificates \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN gem install bundler -v 2.5.6 --no-document
COPY Gemfile Gemfile.lock ./
RUN bundle _2.5.6_ install --jobs 4
COPY app ./app
COPY bin ./bin
COPY config ./config
COPY db ./db
COPY lib ./lib
COPY public ./public
COPY Rakefile config.ru ./
COPY demo/mongoid.yml ./config/mongoid.yml
COPY demo/seeds.rb ./demo/seeds.rb
RUN mkdir -p log tmp/pids storage public/uploads vendor/javascript && chmod +x bin/*
ENV RAILS_ENV=development
EXPOSE 3000
CMD ["sh", "-c", "bundle exec rails db:prepare && bundle exec rails runner demo/seeds.rb && bundle exec rails server -b 0.0.0.0"]
