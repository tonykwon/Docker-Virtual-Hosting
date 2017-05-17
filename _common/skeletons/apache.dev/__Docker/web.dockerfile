FROM httpd:alpine
MAINTAINER Tony Kwon <"tonykwon78@gmail.com">

RUN \
apk update && apk add apache2-proxy && \
sed -i "s/#Include conf\/extra\/httpd-vhosts.conf.*/Include conf\/extra\/httpd-vhosts.conf/g" /usr/local/apache2/conf/httpd.conf && \
sed -i "s/#Include conf\/extra\/httpd-mpm.conf.*/Include conf\/extra\/httpd-mpm.conf/g" /usr/local/apache2/conf/httpd.conf && \
sed -i "s/#LoadModule proxy_module modules\/mod_proxy.so.*/LoadModule proxy_module modules\/mod_proxy.so/g" /usr/local/apache2/conf/httpd.conf && \
sed -i "s/#LoadModule proxy_fcgi_module modules\/mod_proxy_fcgi.so.*/LoadModule proxy_fcgi_module modules\/mod_proxy_fcgi.so/g" /usr/local/apache2/conf/httpd.conf && \
sed -i "s/#LoadModule proxy_http_module modules\/mod_proxy_http.so.*/LoadModule proxy_http_module modules\/mod_proxy_http.so/g" /usr/local/apache2/conf/httpd.conf && \
sed -i "s/#LoadModule slotmem_shm_module modules\/mod_slotmem_shm.so.*/LoadModule slotmem_shm_module modules\/mod_slotmem_shm.so/g" /usr/local/apache2/conf/httpd.conf && \
sed -i "s/#LoadModule rewrite_module modules\/mod_rewrite.so.*/LoadModule rewrite_module modules\/mod_rewrite.so/g" /usr/local/apache2/conf/httpd.conf && \
sed -i "s/#ServerName www.example.com:80.*/ServerName 127.0.0.1:80/g" /usr/local/apache2/conf/httpd.conf && \
rm -rf /var/cache/apk/* /tmp/* /usr/share/man