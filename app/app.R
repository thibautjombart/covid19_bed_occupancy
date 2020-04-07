## This provides a template for making CMMID-branded shiny apps
## key points:
##  - organized as a navbar page
##  - show audience something first: sidebar layouts are all controls-right
##    which means when viewed on mobile, the plot appears first rather than the
##    controls
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
  position="fixed-top",
  collapsible = TRUE,
  
  ## WELCOME PANEL
  tabPanel("Welcome", 
           fluidPage(style="padding-left: 40px; padding-right: 40px; padding-bottom: 40px;", 
                     includeMarkdown("include/heading_box.md"))),

  ## MAIN SIMULATOR PANEL
  tabPanel(
    "Simulator",
    sidebarLayout(
      position = "left",
      
      ## LEFT PANEL: INPUTS
      sidebarPanel(
        h2("Data and parameter inputs", style = sprintf("color:%s", cmmid_color)),
        tabsetPanel(
          
          ## Data inputs
          tabPanel(
            "Data",
            chooseSliderSkin("Shiny", color = slider_color),
            h4("Description", style = sprintf("color:%s", cmmid_color)),
            p("Data inputs specifying the starting point of the forecast: a number of new COVID-19 admissions on a given date at the location considered. Reporting rate refers to the % of COVID-19 admissions reported as such.",
              style = sprintf("color:%s", annot_color)),
            radioButtons(
              "data_source",
              "How do you want to enter data",
              choices = c(
                "Admissions on a single day" = "single",
                "Upload data for multiple days" = "multiple"
              )
            ),
            conditionalPanel(
              condition = sprintf("input.data_source == 'single'"),
              dateInput(
                "admission_date",
                "Date of admission:"),
              numericInput(
                "n_admissions",
                "New admissions that day:",
                min = 1,
                max = 10000,
                value = 1
              )
            ),
            conditionalPanel(
              condition = sprintf("input.data_source == 'multiple'"),
              fileInput("data_file",
                        "Choose data file (.xlsx/.xls/.csv)",
                        multiple = FALSE,
                        accept = c(".xlsx", ".xls", ".csv"))
            ),
            sliderInput(
              "assumed_reporting",
              "Reporting rate (%):",
              min = 10,
              max = 100,
              value = 100,
              step = 5
            )
          ),
          
          ## LOS inputs
          tabPanel(
            "Duration of hospitalisation",
            h4("Description", style = sprintf("color:%s", cmmid_color)),
            p("Parameter inputs specifying the distribution of the length of hospital stay (LoS) for COVID-19 patients.",
              style = sprintf("color:%s", annot_color)),
            selectInput(
              "los",
              "Length of hospital stay (LoS) distribution",
              choices = c("Custom" = "custom",
                          "Zhou et al. non-critical care" = "zhou_general",
                          "Zhou et al. critical care" = "zhou_critical")
            ),
            ## Custom LoS distribution
            ## Discretised Gamma param as mean and cv
            conditionalPanel(
              condition = "input.los == 'custom'",
              sliderInput(
                "mean_los",
                "Average LoS (in days)",
                min = 1.1,
                max = 20,
                value = 7,
                step = .1),
              sliderInput(
                "cv_los",
                "Coefficient of variation",
                min = 0,
                max = 1,
                value = 0.1,
                step = .01),
              htmlOutput("los_ci")
            )
          ),

          ## Epidemic growth inputs
          tabPanel(
            "Growth parameters",
            h4("Description", style = sprintf("color:%s", cmmid_color)),
            p("Parameter inputs specifying the COVID-19 epidemic growth as doubling time and associated uncertainty.",
              style = sprintf("color:%s", annot_color)),
            sliderInput(
              "doubling_time",
              "Assumed doubling time (days):",
              min = 1,
              max = 20,
              value = 7, 
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
            htmlOutput("doubling_ci")
          ),

          ## Simulation parameters
          tabPanel(
            "Simulation parameters",
            h4("Description", style = sprintf("color:%s", cmmid_color)),
            p("Parameter inputs specifying the number and durations of the simulations.",
              style = sprintf("color:%s", annot_color)),
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
          )
        )
      ),
      
      ## RIGHT PANEL: OUTPUTS
      mainPanel(
        tabsetPanel(
          tabPanel(
            "Length of Stay Distribution",
            br(),
            plotOutput("los_plot", width = "30%", height = "300px")
          ),
          tabPanel(
            "Doubling time distribution",
            br(),
            plotOutput("doubling_plot", width = "30%", height = "300px")
          ),
          tabPanel(
            "Main Results",
            br(),
            actionButton("run", "Generate results", icon("play"), style = "align:right"),
            br(),
            br(),
            plotOutput("main_plot", width = "30%", height = "300px"),
            checkboxInput("show_table", "Show summary table?", FALSE),
            conditionalPanel(
              condition = sprintf("input.show_table == true"),
              DT::dataTableOutput("main_table", width = "50%"))
          )
        )
      )        
    )
  ),
  
  ## PANEL WITH MODEL INFO
  tabPanel("Model description", 
           fluidPage(style="padding-left: 40px; padding-right: 40px; padding-bottom: 40px;", 
                     includeMarkdown("include/model.md"))),
  tabPanel("Contact", 
           fluidPage(style="padding-left: 40px; padding-right: 40px; padding-bottom: 40px;", 
                     includeMarkdown("include/contact.md"))),
  ## ACKNOWLEDGEMENTS PANEL
  tabPanel("Acknowledgements", 
           fluidPage(style="padding-left: 40px; padding-right: 40px; padding-bottom: 40px;", 
                     includeMarkdown("include/ack.md")))
)





#################
## SERVER SIDE ##
#################

## Define server logic required to draw a histogram
server <- function(input, output) {

  ## GENERAL PROCESSING OF INPUTS: INTERNAL CONSTRUCTS

  ## data
  data <- reactive({
    if (input$data_source == "single") {
      data.frame(date = input$admission_date,
                 n_admissions = as.integer(input$n_admissions))
    } else {
      x <- rio::import(input$data_file$datapath)
      names(x) <- c("date", "n_admissions")
      x
    }
  })

  
  ## length of stay (returns a `distcrete` object)
  los <- reactive({
    switch(input$los,
           custom =  los_gamma(
             mean = input$mean_los,
             cv = input$cv_los),
           zhou_general = los_zhou_general,
           zhou_critical = los_zhou_critical)
  })

  ## doubling time (returns a vector or r values)
  doubling <-  reactive({
    r_doubling(n = input$number_simulations,
               mean = input$doubling_time,
               cv = input$uncertainty_doubling_time)
  })
  ## same, but larger sample to plot distribution
  doubling_large <-  reactive({
    r_doubling(n = 1e5,
               mean = input$doubling_time,
               cv = input$uncertainty_doubling_time)
  })


  ## main results
  results <- eventReactive(
    input$run,
    run_model(
      date_start = data()$date,
      n_start = data()$n_admissions,
      doubling = doubling(),
      duration = input$simulation_duration,
      r_los = los()$r,
      reporting = input$assumed_reporting / 100,
      n_sim = input$number_simulations),
    ignoreNULL = FALSE
  )



  ## PLOTS  
  ## graph for the distribution of length of hospital stay (LoS)
  output$los_plot <- renderPlot(
    plot_los_distribution(
      los(), "Duration of hospitalisation"
    ), width = 600
  )

  ## graph for the distribution of length of hospital stay (LoS)
  output$doubling_plot <- renderPlot(
    plot_doubling_distribution(
      doubling_large(), "Doubling time distribution"
    ), width = 600
  )

  
  ## main plot: predictions of bed occupancy
  output$main_plot <- renderPlot({
    plot_beds(results(),
              ribbon_color = slider_color,
              palette = cmmid_pal,
              title = "Predicted bed occupancy")
  }, width = 600)
  


  ## TABLES
  
  ## summary tables
  output$main_table <- DT::renderDataTable({
    summarise_beds(results())
  })


  
  ## OTHERS

  ## confidence interval for length of stay
  output$los_ci <- reactive({
    q <- q_los(mean = input$mean_los, 
               cv   = input$cv_los,
               p = c(0.025, 0.975))
    sprintf("<b>LoS 95%% range:</b> (%0.1f, %0.1f)", q[1], q[2])
  })

  ## confidence interval for doubling time 
  output$doubling_ci <- reactive({
    q <- q_doubling(mean = input$doubling_time, 
                    cv   = input$uncertainty_doubling_time,
                    p = c(0.025, 0.975))
    sprintf("<b>Doubling time 95%% range:</b> (%0.1f, %0.1f)", q[1], q[2])
  })

}





#################
## RUN THE APP ##
#################

## Run the application 
shinyApp(ui = ui, server = server)
