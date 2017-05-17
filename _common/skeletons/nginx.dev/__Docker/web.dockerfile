FROM nginx:alpine
MAINTAINER Tony Kwon <"tonykwon78@gmail.com">

ADD ./__Docker/bootstrap.sh /tmp/bootstrap.sh
RUN chmod +x /tmp/bootstrap.sh

ENTRYPOINT ["/tmp/bootstrap.sh"]