FROM httpd:2.4-alpine

LABEL maintainer="your-github-username"
LABEL project="devops-project"
LABEL description="Apache HTTPD DevOps project"

COPY index.html /usr/local/apache2/htdocs/index.html

EXPOSE 80

CMD ["httpd-foreground"]