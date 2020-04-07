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
app_title   <- "Hospital Bed Occupancy Projections   "



##############
## GUI SIDE ##
##############

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
  tabPanel(
    "Simulator",
    sidebarLayout(
      position = "left",
      sidebarPanel(
        chooseSliderSkin("Shiny", color = slider_color),
        actionButton("run", "Run model", icon("play"), style = "align:right"),
        h2("Data input", style = sprintf("color:%s", cmmid_color)),
        p("Data inputs specifying the starting point of the forecast:
        a number of new COVID-19 admissions on a given date at the location considered.
        Reporting rate refers to the % of COVID-19 admissions reported as such.",
        style = sprintf("color:%s", annot_color)),
        dateInput(
          "admission_date",
          "Date of admission:"),
        numericInput(
          "number_admissions",
          "Regular admissions that day:",
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
        h2("Model parameters", style = sprintf("color:%s", cmmid_color)),
        p("Parameter inputs specifying the COVID-19 epidemic growth as doubling time and associated uncertainty. Use more simulations to account for uncertainty in doubling time and length of hospital stay.",
          style = sprintf("color:%s", annot_color)),        
        selectInput(
          "los",
          "Length of hospital stay",
          choices = c("Custom" = "custom",
                      "Zhou et al. non-critical" = "zhou_general",
                      "Zhou et al. critical care" = "zhou_critical")
        ),
        ## Custom LoS distribution
        ## Discretised Gamma param as mean and cv
        conditionalPanel(
          condition = "input.los == 'custom'",
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
            step = .01)#,
          #htmlOutput("los_CI"),
        ),
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
        )
      ),
      ## OUTPUT PANEL
      mainPanel(
        includeMarkdown("include/heading_box.md"),
        tabsetPanel(
          tabPanel(
            "Length of Stay Distribution",
            ##plotOutput("los_plot", width = "30%", height = "300px")
            ),
          tabPanel(
            "Main Results",
            ##plotOutput("los_plot", width = "30%", height = "300px")
            )
        )
        
        
        ## ## br(),
        ## ## plotOutput("main_plot", width = "60%", height = "400px"), 
        ## ## br(),
        ## ## checkboxInput("show_table", "Show summary tables?", FALSE),
        ## ## conditionalPanel(
        ## ##   condition = sprintf("input.%s == true", "show_table"),
        ## ##   DT::dataTableOutput("main_table", width = "50%"))
        ## tabPanel("Length of Stay Distributions")
      )        
    )
  ),
  ## PANEL WITH MODEL INFO
  tabPanel("Information", 
           fluidPage(style="padding-left: 40px; padding-right: 40px; padding-bottom: 40px;", 
                     includeMarkdown("include/info.md"))),
  ## ACKNOWLEDGEMENTS
  tabPanel("Acknowledgements", 
           fluidPage(style="padding-left: 40px; padding-right: 40px; padding-bottom: 40px;", 
                     includeMarkdown("include/ack.md")))
)





#################
## SERVER SIDE ##
#################

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
  output$los_plot <- renderPlot(plot_distribution(
    los_normal, "Duration of normal hospitalisation"
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
  
  
  genbeds <- reactive(do.call(run_model, genpars()))
  
  ## main plot: predictions of bed occupancy
  output$gen_over_plot <- output$gen_main_plot <- renderPlot({
    plot_beds(genbeds(),
              ribbon_color = slider_color,
              palette = cmmid_pal,
              title = "Predicted bed occupancy")
  }, width = 600)
  

  output$doubling_CI <- reactive({
    q <- q_doubling(mean = input$doubling_time, 
                    cv   = input$uncertainty_doubling_time,
                    p = c(0.025, 0.975))
    sprintf("<b>Doubling time 95%% range:</b> (%0.1f, %0.1f)", q[1], q[2])
  })
  
  output$los_CI <- reactive({
    q <- q_los(mean = input$mean_los, 
               cv   = input$cv_los,
               p = c(0.025, 0.975))
    sprintf("<b>LoS 95%% range:</b> (%0.1f, %0.1f)", q[1], q[2])
  })
  
  ## summary tables
  output$gen_main_table <- DT::renderDataTable({
    summarise_beds(genbeds())
  })
  
}

## Run the application 
shinyApp(ui = ui, server = server)
