FROM timbru31/ruby-node:3.0-slim-18

WORKDIR /usr/src/app

COPY . .

# Install dependencies
RUN apt-get update -qq \
    && apt-get install -y \
        build-essential pkg-config

RUN gem install bundler:2.2.14 \
    && bundle install \
    && chmod +x entrypoint.sh

EXPOSE 3000
ENTRYPOINT [ "/usr/src/app/entrypoint.sh" ]
