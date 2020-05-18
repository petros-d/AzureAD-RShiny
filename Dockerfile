FROM rocker/shiny:3.6.1

RUN apt-get update && apt-get install libcurl4-openssl-dev libv8-3.14-dev libssl-dev -y &&\
  mkdir -p /var/lib/shiny-server/bookmarks/shiny

# Download and install library
RUN R -e "install.packages(c('shinydashboard', 'shinyjs', 'V8'))"
RUN install2.r AzureAuth

# copy the app to the image 
COPY shinyapps /srv/shiny-server/
# make all app files readable (solves issue when dev in Windows, but building in Ubuntu)
RUN chmod -R 755 /srv/shiny-server/

EXPOSE 5000

CMD ["/usr/bin/shiny-server.sh"]