library(shiny)
library(AzureAuth)

options(shiny.port=5000)

# parameters -- set the redirect URI for the app to 'Public Client / http://localhost:8100'
resource <- "https://graph.microsoft.com/"
tenant <- "xxxxxxx-254d-43bf-98df-xxxxxxxxx"
app <- "xxxxxxx-ef19-4bd3-9e13-xxxxxxxxx"


has_auth_code <- function(params)
{
    !is.null(params$code)
}

ui <- fluidPage(
    # Your regular UI goes here, for when everything is properly auth'd
    verbatimTextOutput("token")
)

ui_func <- function(req)
{
    if(!has_auth_code(parseQueryString(req$QUERY_STRING)))
    {
        url <- build_authorization_uri(resource, tenant, app, redirect_uri="http://localhost:5000")
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

    token <- get_azure_token(resource, tenant, app, authorize_args=list(redirect_uri="http://localhost:5000"),
                             use_cache=FALSE, auth_code=params$code, auth_type="authorization_code")

    # When specifying the password as below, the authentication flow works as client_credential:                         
    #token <- get_azure_token(c("https://graph.microsoft.com/"),tenant,password="/zY.uiYOA1msV=JaBdZT4YNj5tY_0RVP",
    #                    app,version=2,authorize_args=list(redirect_uri="http://localhost:5000"),use_cache=FALSE, 
    #                    auth_code=params$code)

    output$token <- renderPrint(token)
}

shinyApp(ui_func, server)