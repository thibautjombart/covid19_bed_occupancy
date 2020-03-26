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

admitsPanel <- function(
  prefix, tabtitle
) {
  fmtr = function(inputId) sprintf("%s%s", prefix, inputId)
  return(
    tabPanel(tabtitle, 
             sidebarLayout(position = "left",
                           sidebarPanel(
                             dateInput(fmtr("admission_date"), 
                                       "Date of admission:"),
                             numericInput(fmtr("number_admissions"), 
                                          "Number of admissions on that date:",
                                          min = 1,
                                          max = 10000,
                                          value = 1
                             ),
                             numericInput(fmtr("assumed_reporting"),
                                          "Reporting rate (%):",
                                          min = 10,
                                          max = 100,
                                          value = 100,
                                          step = 10
                             ),
                             numericInput(fmtr("doubling_time"), "Assumed doubling time (days):",
                                          min = 0.5,
                                          max = 10,
                                          value = 5
                             ),
                             numericInput(fmtr("uncertainty_doubling_time"), "Uncertainty in doubling time (%):",
                                          min = 0,
                                          max = 1,
                                          value = .2,
                                          step = 0.05
                             ),
                             numericInput(fmtr("simulation_duration"), "Forecast interval (days):",
                                          min = 1,
                                          max = 21,
                                          value = 7,
                                          step = 1
                             ),
                             numericInput(fmtr("number_simulations"), "Number of simulations:",
                                          min = 10,
                                          max = 50,
                                          value = 10,
                                          step = 10
                             )
                           ),
                           mainPanel(
                             plotOutput(fmtr("los_plot")),
                             br(),
                             plotOutput(fmtr("main_plot"))
                           )
             )))
}

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
  tabPanel("Overall", mainPanel(
    plotOutput("gen_over_plot"),
    br(),
    plotOutput("icu_over_plot")
  )),
  admitsPanel(prefix="gen_", tabtitle="General"),
  admitsPanel(prefix="icu_", tabtitle="ICU"),
  tabPanel("Information", includeMarkdown("info.md"))
)


## Define server logic required to draw a histogram
server <- function(input, output) {
  
  ## graphs for the distributions of length of hospital stay (LoS)
  output$gen_los_plot <- renderPlot({
    los <- los_normal
    title <- "Duration of normal hospitalisation"
    max_days <- max(1, los$q(.999))
    days <- 0:max_days
    
    dat <- data.frame(days = days,
                      y = los$d(days))
    
    ggplot(data=dat,
           aes(x=days, y=y)) +
      geom_col(fill = cmmid_color, width = 0.8) +
      xlab("Days in hospital") +
      ylab("Probability") +
      ggtitle(title) +
      ggplot2::theme_bw() +
      large_txt 
    
    
  }, width = 600)
  
  output$icu_los_plot <- renderPlot({
    los <- los_critical
    title <- "Duration of ICU hospitalisation"
    max_days <- max(1, los$q(.999))
    days     <- 0:max_days
    dat <- data.frame(days = days,
                      y = los$d(days))
    
    ggplot(data=dat,
           aes(x=days, y=y)) +
      geom_col(fill = cmmid_color, width = 0.8) +
      xlab("Days in hospital") +
      ylab("Probability") +
      ggtitle(title) +
      ggplot2::theme_bw() +
      large_txt 
  }, width = 600)
  
  ## main plot: predictions of bed occupancy
  output$gen_over_plot <- output$gen_main_plot <- renderPlot({
    
    los <- los_normal
    title <- "Normal hospital bed utilisation"
    
    ## run model
    beds <- run_model(date = input$gen_admission_date,
                      n_start = as.integer(input$gen_number_admissions),
                      doubling = input$gen_doubling_time,
                      doubling_error = input$gen_uncertainty_doubling_time,
                      duration = input$gen_simulation_duration,
                      reporting = input$gen_assumed_reporting / 100,
                      r_los = los$r,
                      n_sim = input$icu_number_simulations)
    plot_beds(beds, ribbon_color = cmmid_color) +
      ggtitle(title)
  }, width = 600)
  
  output$icu_over_plot <- output$icu_main_plot <- renderPlot({
    
    los <- los_critical
    title <- "ICU bed utilisation"
    
    ## run model
    beds <- run_model(date = input$icu_admission_date,
                      n_start = as.integer(input$icu_number_admissions),
                      doubling = input$icu_doubling_time,
                      doubling_error = input$icu_uncertainty_doubling_time,
                      duration = input$icu_simulation_duration,
                      reporting = input$icu_assumed_reporting / 100,
                      r_los = los$r,
                      n_sim = input$icu_number_simulations)
    plot_beds(beds, ribbon_color = cmmid_color) +
      ggtitle(title)
  }, width = 600)
  
}

## Run the application 
shinyApp(ui = ui, server = server)
