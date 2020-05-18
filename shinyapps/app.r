library(shiny)
library(AzureAuth)

options(shiny.port=5000)

# parameters -- set the redirect URI for the app to 'Public Client / http://localhost:8100'
resource <- c("https://graph.microsoft.com/.default", "openid", "profile", "offline_access", "email" )
tenant <- "xxxxxxx-254d-43bf-98df-xxxxxxxxx"
app <- "xxxxxxx-a844-4a4b-b48f-xxxxxxxx"


has_auth_code <- function(params)
{
    !is.null(params$code)
}

ui <- fluidPage(
    # Your regular UI goes here, for when everything is properly auth'd
    verbatimTextOutput("token"),
    verbatimTextOutput("id")
)

ui_func <- function(req)
{
    if(!has_auth_code(parseQueryString(req$QUERY_STRING)))
    {
        url <- build_authorization_uri(resource, tenant, app, redirect_uri="http://localhost:5000", version=2)
        redirect <- sprintf("location.replace(\"%s\");", url)
        tags$script(HTML(redirect))
    }
    else ui
}

server <- function(input, output, session)
{
    params <- parseQueryString(isolate(session$clientData$url_search))
    if(!has_auth_code(params))
        return()

    token <- get_azure_token(resource=resource, tenant, app, authorize_args=list(redirect_uri="http://localhost:5000"),
                             use_cache=FALSE, version=2, auth_code=params$code)

    output$token <- renderPrint(token)
    output$id <- renderPrint(decode_jwt(token, "id"))
}

shinyApp(ui_func, server)