docker build -t azuread/rshiny .

docker run --name=rshiny-azuread --user shiny --rm -p 5000:5000 azuread/rshiny

docker rm rshiny-azuread -f