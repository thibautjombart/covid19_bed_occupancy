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
    "tabtitle",
    sidebarLayout(
      position = "left",
      sidebarPanel(),
      ## OUTPUT PANEL
      mainPanel(
        includeMarkdown("include/heading_box.md"),
        tabsetPanel(
          tabPanel("Length of Stay Distribution",
                   ##plotOutput("los_plot", width = "30%", height = "300px")
           ),
          tabPanel("Main Results",
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
