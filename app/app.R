# this provides a template for making CMMID-branded shiny apps
# key points:
#  - organized as a navbar page
#  - show audience something first: sidebar layouts are all controls-right
#    which means when viewed on mobile, the plot appears first rather than the controls
#  - the notes markdown is the place to document any long form details.

library(shiny)

apptitle <- "Hospital Bed Occupancy Projections"

source("old_faithful.R")
source("exp_growth.R")

# Define UI for application that draws a histogram
ui <- navbarPage(
    title = div(
        a(img(src="cmmid_newlogo.svg", height="45px"), href="https://cmmid.github.io/"), span(apptitle, style="line-height:45px")
    ),
    windowTitle = apptitle,
    theme = "styling.css",
    position="fixed-top", collapsible = TRUE,
    tabPanel("Results", sidebarLayout(position = "right",
      sidebarPanel(
        numericInput("R",
          "R:",
          min = 0.5,
          max = 10,
          value = 2
        ),
        numericInput("SI",
                     "serial interval:",
                     min = 1,
                     max = 10,
                     value = 5
        )
      ),
      mainPanel(
        plotOutput("growthPlot")
      )
    )),
    tabPanel("Event Time Distributions", sidebarLayout(position = "right",
        sidebarPanel(
            sliderInput("bins1",
                        "Number of bins 1:",
                        min = 1,
                        max = 50,
                        value = 30),
            sliderInput("bins2",
                        "Number of bins 2:",
                        min = 1,
                        max = 50,
                        value = 30),
            sliderInput("bins3",
                        "Number of bins 3:",
                        min = 1,
                        max = 50,
                        value = 30)
        ),
        mainPanel(
            plotOutput("distPlot1"),
            plotOutput("distPlot2"),
            plotOutput("distPlot3")
        )
    )),
    tabPanel("Information", includeMarkdown("info.md"))
)
# Define server logic required to draw a histogram
server <- function(input, output) {
    output$growthPlot <- renderPlot(exp_growth(input$R, input$SI))
    output$distPlot1 <- renderPlot(old_faithful(input$bins1))
    output$distPlot2 <- renderPlot(old_faithful(input$bins2))
    output$distPlot3 <- renderPlot(old_faithful(input$bins3))
}

# Run the application 
shinyApp(ui = ui, server = server)
