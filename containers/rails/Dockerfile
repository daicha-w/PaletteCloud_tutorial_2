FROM ruby:2.7.5

RUN apt-get update
RUN apt-get install -y gtk2.0

RUN apt-get update -qq && \ 
    apt-get install -y build-essential \
    libpq-dev \
    nodejs \
    mariadb-client

WORKDIR /usr/src/app

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

RUN gem install bundler

RUN bundler install

# 全コピー
COPY . /usr/src/app

# puma
EXPOSE 80
CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]