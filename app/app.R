## This provides a template for making CMMID-branded shiny apps
## key points:
##  - organized as a navbar page
##  - show audience something first: sidebar layouts are all controls-right
##    which means when viewed on mobile, the plot appears first rather than the controls
##  - the notes markdown is the place to document any long form details.



## load R files in R/
R_files <- dir("R", pattern = "[.]R$", full.names = TRUE)
for (e in R_files) source(e, local = TRUE)

## load required packages
library(shiny)
library(incidence)
library(projections)
library(distcrete)


## global variables
app_title <- "Hospital Bed Occupancy Projections"
cmmid_color <- "#134e51"

## Define UI for application that draws a histogram
ui <- navbarPage(
    title = div(
        a(img(src="cmmid_newlogo.svg", height="45px"),
          href="https://cmmid.github.io/"),
        span(app_title, style="line-height:45px")
    ),
    windowTitle = app_title,
    theme = "styling.css",
    position="fixed-top", collapsible = TRUE,
    tabPanel("Results", sidebarLayout(position = "left",
      sidebarPanel(
        dateInput("admission_date",
          "Date of admission:"
        ),
        numericInput("number_admissions",
                     "Number of admissions on that date:",
                     min = 1,
                     max = 10000,
                     value = 1
        ),
        numericInput("assumed_reporting",
                     "Reporting rate (%):",
                     min = 1,
                     max = 100,
                     value = 100
        ),
        numericInput("doubling_time",
                     "Assumed doubling time (days):",
                     min = 0.5,
                     max = 10,
                     value = 5
        ),
        numericInput("uncertainty_doubling_time",
                     "Uncertainty in doubling time (days):",
                     min = 0,
                     max = 5,
                     value = 1
        ),
        radioButtons(inputId = "distribution_duration",
                     label = "Distribution of duration of stay", 
                     choices = c("non-critical hospitalization" = "normal",
                                "critical hospitalization" = "critical")
        ),
        numericInput("simulation_duration",
                     "Duration of the simulation (days):",
                     min = 1,
                     max = 21,
                     value = 7
        ),
        numericInput("number_simulations",
                     "Number of simulations:",
                     min = 1,
                     max = 50,
                     value = 10
        )
      ),
      mainPanel(
          plotOutput("los_plot"),
          plotOutput("main_plot")
      )
    )),
    tabPanel("Information", includeMarkdown("info.md"))
)


## Define server logic required to draw a histogram
server <- function(input, output) {

  ## graphs for the distributions of length of hospital stay (LoS)
  output$los_plot <- renderPlot({
    
    ## select appropriate distribution
    if (input$distribution_duration == "normal") {
      los <- los_normal
      title <- "Duration of normal hospitalisation"
    } else {
      los <- los_critical
      title <- "Duration of critical care hospitalisation"
    }

    max_days <- max(1, los$q(.999))
    days <- 0:max_days
    plot(days,
         los$d(days),
         type = "h", col = cmmid_color,
         lwd = 14, lend = 2,
         xlab = "Days in hospital",
         ylab = "Probability",
         main = title,
         cex.lab = 1.3,
         cex.main = 1.5)
  }, width = 600)

  
  ## main plot: predictions of bed occupancy
  output$main_plot <- renderPlot({

    ## select appropriate distribution
    if (input$distribution_duration == "normal") {
      los <- los_normal
      title <- "Duration of normal hospitalisation"
    } else {
      los <- los_critical
      title <- "Duration of critical care hospitalisation"
    }

    ## run model
    beds <- run_model(date = input$admission_date,
                      n_start = as.integer(input$number_admissions),
                      doubling = input$doubling_time,
                      doubling_error = input$uncertainty_doubling_time,
                      duration = input$simulation_duration,
                      reporting = input$assumed_reporting / 100,
                      r_los = los$r,
                      n_sim = input$number_simulations)
    plot_beds(beds, ribbon_color = cmmid_color)
  })

}

## Run the application 
shinyApp(ui = ui, server = server)
