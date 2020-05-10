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
library(linelist)
library(patchwork)
library(fitdistrplus)

## global variables
app_title   <- "Hospital bed occupancy projections"
url_template <- "https://github.com/thibautjombart/covid19_bed_occupancy/blob/master/app/extra/data_model.xlsx?raw=true"


##############
## GUI SIDE ##
##############

## Define UI for application
ui <- navbarPage(
  title = NULL,
  theme = "styling.css",
  position="fixed-top",
  collapsible = FALSE,
  
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
        h2(app_title, style = sprintf("color:%s", cmmid_color)),
        
        
        ## Data inputs
        conditionalPanel(
          condition = "input.outputPanels == 'Admissions'",
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
              "New admissions reported that day:",
              min = 1,
              max = 10000,
              value = 1
            )
          ),
          conditionalPanel(
            condition = sprintf("input.data_source == 'multiple'"),
            div(
              strong("1. Download our data template"),
              HTML(
                sprintf("<a href='%s'>here</a>.",
                        url_template)
              )
            ),
            div(
              strong(
                "2. Enter your data into the template, save as a new file."
              )
            ),
            fileInput("data_file",
                      "3. Upload this file here (.xlsx/.xls)",
                      multiple = FALSE,
                      accept = c(".xlsx", ".xls"))
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
        
        ## LoS inputs
        conditionalPanel(
          condition = sprintf("input.outputPanels == 'Length of Stay'"),
          #"Length of stay in hospital",
          h4("Description", style = sprintf("color:%s", cmmid_color)),
          p("Parameter inputs specifying the distribution of the length of hospital stay (LoS) for COVID-19 patients. See the 'Inputs' tab for details on these distributions.",
            style = sprintf("color:%s", annot_color)),
          selectInput(
            "los",
            "Length of hospital stay (LoS) distribution",
            choices = unique(los_parameters$name),
            selected = "Custom"
          ),
          ## Custom LoS distribution
          ## Discretised Gamma param as mean and cv
          
          radioButtons(inputId = "los_dist",
                       label = "Distribution", 
                       choices = unique(los_parameters$los_dist),
                       selected = "gamma"),
          sliderInput(
            "mean_los",
            "Average LoS (in days)",
            min = 1.1,
            max = 20,
            value = 7,
            step = .1),
          sliderInput(
            "cv_los",
            HTML("Uncertainty as fraction of avg. (<i>c<sub>v,L</sub></i>)"),
            min = 0.01,
            max = 2,
            value = 0.1,
            step = .01)),
        
        
        
        ## Epidemic growth inputs
        conditionalPanel(
          condition = "input.outputPanels == 'Epidemic Parameters'",
          h4("Description", style = sprintf("color:%s", cmmid_color)),
          p("Parameter inputs specifying the COVID-19 epidemic growth in terms of basic reproduction number and serial interval (and associated uncertainties). See the 'Inputs' tab for details on the serial interval distribution.",
            style = sprintf("color:%s", annot_color)),
          radioButtons("specifyepi", label = "How do you wish to specify the epidemic growth?",
                       choices = c("Branching process",
                                   "Doubling time"),
                       selected = "Doubling time"),
          conditionalPanel(
            condition = "input.specifyepi == 'Branching process'",
            sliderInput(
              inputId = "r0",
              label = HTML("Average basic reproduction number, <i>R</i><sub>0</sub>"),
              min=0.1, max=5, step=0.1, 
              value=2.5),  
            sliderInput(
              "uncertainty_r0",
              HTML("Uncertainty as fraction of avg. <i>R</i><sub>0</sub> (<i>c<sub>v,R<sub>0</sub></sub></i>)"),
              min = 0,
              max = 0.5,
              value = 0.26,
              step = 0.01
            ),
            sliderTextInput(
              "dispersion",
              HTML("Dispersion of <i>R</i><sub>0</sub>"),
              choices = c("0.1", "0.54"),
              selected = "0.54"
            ),
            sliderInput(
              "serial_interval",
              "Average serial interval (days):",
              min = 1,
              max = 20,
              value = 7.5, 
              step = 0.1
            ),
            sliderInput(
              "uncertainty_serial_interval",
              HTML("Uncertainty as fraction of avg. serial interval (<i>c<sub>v,S</sub></i>)"),
              min = 0,
              max = 2,
              value = 0.45,
              step = 0.01
            )),
          conditionalPanel(
            condition = "input.specifyepi == 'Doubling time'",
            sliderInput(
              "doubling_time",
              "Average doubling time (days):",
              min = 1,
              max = 20,
              value = 7, 
              step = 0.1
            ),
            sliderInput(
              "uncertainty_doubling_time",
              HTML("Uncertainty as fraction of avg. serial interval (<i>c<sub>v,T</sub></i>)"),
              min = 0,
              max = 1,
              value = 0.1,
              step = 0.01
            )
          )
        ),
        
        ## Simulation parameters
        conditionalPanel(
          condition = "input.outputPanels == 'Main results'",
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
            value = 10,
            step = 10
          ),
          br(),
          actionButton("run", "Generate results", icon("play"), style = "align:right"),
          br()
          
        )
      ),
      
      ## RIGHT PANEL: OUTPUTS
      mainPanel(
        tabsetPanel(
          id = "outputPanels",
          tabPanel(
            "Admissions",
            id = "admissions_tab",
            br(),
            plotOutput("data_plot", width = "100%", height = "300px")
          ),
          tabPanel(
            "Length of Stay",
            
            br(),
            plotOutput("los_plot", width = "100%", height = "300px"),
            br(),
            htmlOutput("los_ci")
          ),
          tabPanel(
            "Epidemic Parameters",
            
            br(),
            
            conditionalPanel(condition = "input.specifyepi == 'Doubling time'",
                             plotOutput("doubling_plot", width = "30%", height = "300px"),
                             br(),
                             htmlOutput("doubling_ci")
            ),
            # need to amend this panel to have three fluidrows and two columns each,
            # plot in left col, summary on right
            conditionalPanel(condition = "input.specifyepi == 'Branching process'",
                             
                             fluidRow(
                               column(6, plotOutput("r0_plot", height = "200px")),
                               column(6, br(), br(), htmlOutput("r0_ci"))),
                             
                             fluidRow(
                               column(6, plotOutput("secondary_plot", height = "200px")),
                               column(6, br(), br(), htmlOutput("secondary_ci"))),
                             br(),
                             fluidRow(
                               column(6, plotOutput("serial_plot", height = "200px")),
                               column(6, br(), br(), htmlOutput("serial_ci")))
            )
            
            
            
          ),
          tabPanel(
            "Main results",
            
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
  tabPanel("Inputs", 
           fluidPage(style="padding-left: 40px; padding-right: 40px; padding-bottom: 40px;", 
                     includeMarkdown("include/inputs.md"))),
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
server <- function(input, output, session) {
  
  ## SELECTION OF PARAMETERS GIVEN DROP DOWN MENU
  
  
  
  
  observe({
    default=input$los
    
    updateSliderInput(session, "mean_los",
                      value = c(los_parameters[los_parameters$name == default, "mean_los"]))
    
    updateSliderInput(session, "cv_los",
                      value = c(los_parameters[los_parameters$name == default, "cv_los"]))
    
    updateRadioButtons(session, "los_dist",
                       selected = c(los_parameters[los_parameters$name == default, "los_dist"]))
    
    
  }
  
  )
  
  
  ## GENERAL PROCESSING OF INPUTS: INTERNAL CONSTRUCTS
  
  ## data
  data <- reactive({
    if (input$data_source == "single") {
      data.frame(date = input$admission_date,
                 n_admissions = as.integer(input$n_admissions))
    } else if (length(input$data_file$datapath)) {
      x <- rio::import(input$data_file$datapath, guess_max = 1e5)
      x <- check_uploaded_data(x)
    } else {
      # hacky and i hate it
      data.frame(date = input$admission_date,
                 n_admissions = as.integer(input$n_admissions))
    }
  })
  
  
  ## length of stay (returns a `distcrete` object)
  los <- reactive({
    los_dist(
      distribution          = input$los_dist,
      mean                  = input$mean_los,
      cv                    = input$cv_los)
  })
  
  ## doubling time (returns a vector of doubling time values)
  doubling <-  reactive({
    r_doubling(n       = input$number_simulations,
               mean    = input$doubling_time,
               cv      = input$uncertainty_doubling_time)
  })
  ## same, but larger sample to plot distribution
  doubling_large <-  reactive({
    r_doubling(n = 1e5,
               mean    = input$doubling_time,
               cv      = input$uncertainty_doubling_time)
  })
  
  output$data_plot <- renderPlot({
    
    ggdata <- data()
    reporting <- input$assumed_reporting
    simulation_duration <- input$simulation_duration
    plot_data(data = ggdata, reporting = reporting, simulation_duration)
    
  })
  
  si <- reactive({
    make_si(mean = input$serial_interval,
            cv   = input$uncertainty_serial_interval)
  })
  
  R <- reactive({
    make_r0(n    = input$number_simulations,
            mean = input$r0,
            cv   = input$uncertainty_r0)
  })
  
  R_large <-  reactive({
    make_r0(n    = 1e5,
            mean = input$r0,
            cv   = input$uncertainty_r0)
  })
  
  ## main results
  results <- eventReactive(
    input$run,
    if (!is.null(data())) {
      
      if(input$specifyepi == "Doubling time"){
        doubling_ <- doubling()} else {
          doubling_ <- NULL
        }
      
      run_model(
        dates = data()$date,
        admissions = data()$n_admissions,
        doubling = doubling_,
        R = R()$R0,  
        si = si(),
        dispersion = as.numeric(input$dispersion),
        duration = input$simulation_duration,
        r_los = los()$r,
        reporting = input$assumed_reporting / 100,
        n_sim = input$number_simulations)
    } else {
      NULL
    },
    ignoreNULL = FALSE
  )
  
  
  
  ## PLOTS  
  ## graph for the distribution of length of hospital stay (LoS)
  output$los_plot <- renderPlot(
    plot_los_distribution(
      los(), 
      title = "Length of stay in hospital",
      x     = "Days in hospital",
      y     = "Density"
    )
  )
  
  output$r0_plot <- renderPlot(
    plot_r0(
      R_large()
    ), width = 300, height = 200
      #function() {
      #0.6*session$clientData$output_r0_plot_width
    #}
  )
  
  output$secondary_plot <- renderPlot(
    plot_secondary(
      R_large(),
      dispersion = input$dispersion
    ), width = 300, height = 200
  )
  
  # output$secondary_plot <- renderPlot(
  #   plot_branching(R = R_large(),
  #                  dispersion = as.numeric(input$dispersion)
  #   ), width = 300
  # )
  
  output$serial_plot <- renderPlot({
    plot_los_distribution(los = si(), 
                          title = "Serial interval", 
                          x = "Days to secondary case",
                          y = "Density")
  }, width = 300, height = 200
  )
  
  ## graph for the distribution of length of hospital stay (LoS)
  output$doubling_plot <- renderPlot(
    plot_doubling_distribution(
      doubling_large(), title =  "Epidemic doubling time", 
      x = "Days", 
      y = "Density"
    ), width = 600
  )
  
  
  ## main plot: predictions of bed occupancy
  output$main_plot <- renderPlot({
    plot_beds(results(),
              ribbon_color = slider_color,
              palette = cmmid_pal,
              title = "Projected bed occupancy")
  }, width = 600)
  
  
  
  ## TABLES
  
  ## summary tables
  output$main_table <- DT::renderDataTable({
    summarise_beds(results())
  })
  
  
  
  ## OTHERS
  
  ## confidence interval for length of stay
  output$los_ci <- reactive({
    q <- q_los(distribution = input$los_dist,
               mean = input$mean_los, 
               cv   = input$cv_los,
               p = c(0.025, 0.5, 0.975))
    #sprintf("<b>LoS distribution:</b> %s(%0.1f, %0.1f)", )
    sprintf("<b>Median LoS:</b> %0.1f days<br>
            <b>95%% interval</b>: (%0.1f, %0.1f) days<br>
            <b>Distribution:</b> %s(<i>%s</i>=%0.1f, <i>%s</i>=%0.1f)",
            q$q[2], q$q[1], q$q[3], q$short_name,
            q$params_names[1], q$params[1],
            q$params_names[2], q$params[2])
  })
  
  ## confidence interval for doubling time 
  output$serial_ci <- reactive({
    
    if (input$uncertainty_serial_interval > 0){
      
      q <- q_doubling(mean = input$serial_interval, 
                      cv   = input$uncertainty_serial_interval,
                      p = c(0.025, 0.5, 0.975))
      
      
      sprintf("<b>Median serial interval:</b> %0.1f days<br>
            <b>95%% interval:</b> (%0.1f, %0.1f) days<br>
            <b>Distribution:</b> %s(<i>%s</i>=%0.1f, <i>%s</i>=%0.1f)",
              q$q[2], q$q[1], q$q[3], q$short_name,
              q$params_names[1], q$params[1],
              q$params_names[2], q$params[2])
    } else {
      sprintf("<b>Fixed serial interval:</b> %0.1f days<br>",
              input$serial_interval)
    }
  })
  
  output$doubling_ci <- reactive({
    
    q <- q_doubling(mean = input$doubling_time,
                    cv = input$uncertainty_doubling_time, p = c(0.025, 0.5, 0.975))
    
    # 
    # 
    # flag_text <- switch(flag + 1, 
    #                     "",
    #                     "The lower bound of the doubling time distribution is negative. This indicates that the epidemic may be growing slowly and close to stable.",
    #                     "The average doubling time is negative, indicating that the epidemic may be close to stable and decreasing towards extinction and this time should be interpreted as a <i>halving</i> time.",
    #                     "The doubling time is negative, indicating that the epidemic is decreasing towards extinction and this time should be interpreted as a <i>halving</i> time.")
    
    
    
    sprintf("<b>Median doubling time:</b> %0.1f days<br>
            <b>95%% interval:</b> (%0.1f, %0.1f)<br>
            <b>Distribution:</b> %s(<i>%s</i>=%0.1f, <i>%s</i>=%0.1f)",
            q$q[2], q$q[1], q$q[3], q$short_name,
            q$params_names[1], q$params[1],
            q$params_names[2], q$params[2])
    
    
    
  })
  
  output$r0_ci <- reactive({
    
    if (input$uncertainty_r0 > 0){
      
      q <- q_r0(mean = input$r0, 
                cv   = input$uncertainty_r0,
                p = c(0.025, 0.5, 0.975))
      
      sprintf("<b>Median <i>R</i><sub>0</sub>:</b> %0.1f<br>
            <b>95%% interval:</b> (%0.1f, %0.1f)<br>
            <b>Distribution:</b> %s(<i>%s</i>=%0.1f, <i>%s</i>=%0.1f)",
              q$q[2], q$q[1], q$q[3], q$short_name,
              q$params_names[1], q$params[1],
              q$params_names[2], q$params[2])
    } else {
      sprintf("<b>Fixed <i>R</i><sub>0</sub>:</b> %0.1f<br>",
              input$r0)
    }
  })
  
  output$secondary_ci <- reactive({
    
    
    q <- q_secondary(R_large(),
                     input$dispersion,
                     p = c(0.025, 0.5, 0.975))
    
    sprintf("<b>Median secondary cases:</b> %0.1f<br>
            <b>95%% interval:</b> (%0.1f, %0.1f)<br>
            <b>Distribution:</b> %s(<i>%s</i>=%0.1f, <i>%s</i>=%0.2f)",
            q$q[2], q$q[1], q$q[3], q$short_name,
            q$params_names[1], q$params[1],
            q$params_names[2], q$params[2])
    
  })
  
}





#################
## RUN THE APP ##
#################

## Run the application 
shinyApp(ui = ui, server = server)
