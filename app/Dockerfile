FROM ruby:3.2.2

WORKDIR /app

RUN apt-get update -qq && apt-get install -y libsqlite3-dev

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 8000

CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "8000"]