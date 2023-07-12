FROM timbru31/ruby-node:3.0-slim-16

WORKDIR /usr/src/app

COPY . .

RUN gem install bundler:2.2.14 \
    && bundle install \
    && chmod +x entrypoint.sh

EXPOSE 3000
ENTRYPOINT [ "/usr/src/app/entrypoint.sh" ]
