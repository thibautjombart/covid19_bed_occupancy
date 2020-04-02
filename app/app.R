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
library(shinyWidgets)
library(incidence)
library(projections)
library(distcrete)
library(epitrix)
library(ggplot2)
library(invgamma)
library(markdown)


## global variables
app_title   <- "Hospital Bed Occupancy Projections"


admitsPanel <- function(prefixes, tabtitle) {
  fmtr = function(inputId, ind) {
    sprintf("%s%s", prefixes[ind], inputId)
  }
  
  return(
  tabPanel(tabtitle, sidebarLayout(position = "left",
  sidebarPanel(
      chooseSliderSkin("Shiny", color = slider_color),
      actionButton("run", "Run model", icon("play"), style = "align:right"),
      
      h2("Starting conditions", style = sprintf("color:%s", cmmid_color)),
      
      p("Data inputs specifying the starting point of the forecast:
        a number of new COVID-19 admissions on a given date at the location considered.
        Reporting refers to the % of admissions notified.",
        style = sprintf("color:%s", annot_color)),
      dateInput(
          "admission_date",
          "Date of admission:"),
      numericInput(
          fmtr("number_admissions", 1),
          "Regular admissions that day:",
          min = 1,
          max = 10000,
          value = 1
      ),
      numericInput(
        fmtr("number_admissions", 2),
        "ICU admissions that day:",
        min = 1,
        max = 10000,
        value = 1
      ),
      sliderInput(
          "assumed_reporting",
          "Reporting rate (%):",
          min = 10,
          max = 100,
          value = 100,
          step = 5
      ),
      br(),
      h2("Model parameters", style = sprintf("color:%s", cmmid_color)),
      p("Parameter inputs specifying the COVID-19 epidemic growth as doubling time and associated uncertainty. Use more simulations to account for uncertainty in doubling time and length of hospital stay.",
        style = sprintf("color:%s", annot_color)),
      sliderInput(
          "doubling_time",
          "Assumed doubling time (days):",
          min = 0.5,
          max = 10,
          value = 5, 
          step = 0.1
      ),
      sliderInput(
          "uncertainty_doubling_time",
          "Uncertainty in doubling time (coefficient of variation):",
          min = 0,
          max = 0.5,
          value = 0.1,
          step = 0.01
      ),
      htmlOutput("doubling_CI"),
      br(),
      sliderInput(
          "simulation_duration",
          "Forecast period (days):",
          min = 1,
          max = 21,
          value = 7,
          step = 1
      ),
      sliderInput(
          "number_simulations",
          "Number of simulations:",
          min = 10,
          max = 100,
          value = 30,
          step = 10
      ),
      ## Custom LoS distribution
      ## Discretised Gamma param as mean and cv
      checkboxInput("custom_los", "Specify length of stay (LoS)?", FALSE),
      conditionalPanel(
          condition = sprintf("input.%s == true", "custom_los"),
          sliderInput(
              "mean_los",
              "Average LoS (in days)",
              min = 1,
              max = 20,
              value = 7,
              step = .1),
          sliderInput(
              "cv_los",
              "Coefficient of variation",
              min = 0,
              max = 2,
              value = 0.1,
              step = .01)
      )
  ),
  mainPanel(
      includeMarkdown("include/heading_box.md"),
      br(),
      plotOutput(fmtr("main_plot", 1), width = "60%", height = "400px"), 
      plotOutput(fmtr("main_plot", 2), width = "60%", height = "400px"),
      br(),
      checkboxInput("show_table", "Show summary tables?", FALSE),
      conditionalPanel(
          condition = sprintf("input.%s == true", "show_table"),
          DT::dataTableOutput(fmtr("main_table",1), width = "50%"),
          DT::dataTableOutput(fmtr("main_table",2), width = "50%")
      ),
      
  )
  )))
}

## Define UI for application
ui <- navbarPage(
  title = div(
    a(img(src="cmmid_newlogo.svg", height="45px"),
      href="https://cmmid.github.io/"),
    span(app_title, style="line-height:45px")
  ),
  windowTitle = app_title,
  theme = "styling.css",
  position="fixed-top", collapsible = TRUE,
  admitsPanel(prefixes = c("gen_","icu_"), tabtitle = "Forecasts"),
  tabPanel("Length of Stay Distributions",
    plotOutput("gen_los_plot", width = "30%", height = "300px"),
    plotOutput("icu_los_plot", width = "30%", height = "300px")
  ),
  tabPanel("Information", 
           fluidPage(style="padding-left: 40px; padding-right: 40px; padding-bottom: 40px;", 
                     includeMarkdown("include/info.md"))),
  tabPanel("Acknowledgements", 
           fluidPage(style="padding-left: 40px; padding-right: 40px; padding-bottom: 40px;", 
                     includeMarkdown("include/ack.md")))
  

)

## Define server logic required to draw a histogram
server <- function(input, output) {

  ## generate custom LoS if needed
  ## this can be used elsewhere using `custom_los()`
  custom_los <- reactive({
    if (input$custom_los) {
      los_gamma(mean = input$mean_los,
                cv = input$cv_los)
    } else {
      NULL
    }
  })
  
  ## graphs for the distributions of length of hospital stay (LoS)
  output$gen_los_plot <- renderPlot(plot_distribution(
    los_normal, "Duration of normal hospitalisation"
  ), width = 600)

  output$icu_los_plot <- renderPlot(plot_distribution(
    los_critical, "Duration of ICU hospitalisation"
  ), width = 600)
  
  sharedpars <- reactive(list(
    date = input$admission_date,
    doubling = r_doubling(n = input$number_simulations,
                          mean = input$doubling_time,
                          cv = input$uncertainty_doubling_time),
    duration = input$simulation_duration,
    reporting = input$assumed_reporting / 100
  ))
  
  genpars <- eventReactive(input$run, c(list(
    n_start = as.integer(input$gen_number_admissions),
    r_los = los_normal$r
  ), sharedpars()), ignoreNULL = FALSE)
  
  icupars <- eventReactive(input$run, c(list(
    n_start = as.integer(input$icu_number_admissions),
    r_los = los_critical$r
  ), sharedpars()), ignoreNULL = FALSE)
  
  genbeds <- reactive(do.call(run_model, genpars()))
  icubeds <- reactive(do.call(run_model, icupars()))
  
  ## main plot: predictions of bed occupancy
  output$gen_over_plot <- output$gen_main_plot <- renderPlot({
    plot_beds(genbeds(),
    ribbon_color = slider_color,
    palette = cmmid_pal,
    title = "Non-critical care bed occupancy")
  }, width = 600)
  
  output$icu_over_plot <- output$icu_main_plot <- renderPlot({
    plot_beds(icubeds(),
    ribbon_color = slider_color,
    palette = cmmid_pal,
    title = "Critical care bed occupancy")
  }, width = 600)

  output$doubling_CI <- reactive({
    q <- q_doubling(mean = input$doubling_time, 
                    cv   = input$uncertainty_doubling_time,
                    p = c(0.025, 0.975))
    sprintf("<b>Doubling time 95%% range:</b> (%0.1f, %0.1f)", q[1], q[2])
  })
  
  ## summary tables
  output$gen_main_table <- DT::renderDataTable({
    summarise_beds(genbeds())
  })
  output$icu_main_table <- DT::renderDataTable({
    summarise_beds(icubeds())
  })

  
}

## Run the application 
shinyApp(ui = ui, server = server)
