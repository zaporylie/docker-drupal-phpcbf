FROM zaporylie/drupal-phpcs:release-0.3

MAINTAINER Jakub Piasecki <jakub@piaseccy.pl>

ENV GIT_USERNAME=phpcbf \
  GIT_USEREMAIL=phpcbf@drupal.org

RUN curl -L -O https://github.com/github/hub/releases/download/v2.2.2/hub-linux-amd64-2.2.2.tgz && tar -xvzf hub-linux-amd64-2.2.2.tgz && ./hub-linux-amd64-2.2.2/install && hub version

COPY ./fix.sh /tmp/fix.sh

RUN chmod +x /tmp/fix.sh

CMD ["/tmp/fix.sh"]
