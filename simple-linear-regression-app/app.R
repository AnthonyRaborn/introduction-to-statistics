#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

ui <- fluidPage(

    # Application title
    titlePanel("Determine the Regression Parameters"),

    sidebarLayout(
        sidebarPanel(
          actionButton('generateData',
                       "Generate new data")
          , br(), br()
          , numericInput("y_intercept",
                      "Select a y-intercept:",
                      value = 1,
                      min = -25,
                      max = 25)
          , numericInput("x_slope",
                         "Select a slope:",
                         value = 0,
                         min = -15,
                         max = 15)
          , h6("Data summary:")
          , htmlOutput("summary_info")
          , htmlOutput("summary_info2")
          , br()
          , actionButton('hint', "Hint!")
        ),

        # Show a plot of the generated data and chosen line
        mainPanel(
           plotOutput("distPlot", width = '100%')
           , textOutput("sum_sq_error")
           , actionButton("show_solution", "Show Solution")
        )
    )
)

server <- function(input, output) {

  observeEvent(input$hint, {
    showModal(modalDialog(
      title = "Hint:",
      withMathJax(
        "We can solve for the slope with this equation: 
        $$\\hat{\\beta_1} = \\frac{\\Sigma_{i-1}^n (x_i - \\bar{x})(y_i - \\bar{y})}{SS(x)}$$
        We can then solve for the intercept with this equation: 
        $$\\hat{\\beta_0} = \\bar{y} - \\hat{\\beta_1}*\\bar{x}$$"
      )
    ))
  })
  
  observeEvent(input$show_solution, {
    showModal(modalDialog(
      title = "Solution:",
      {
        fit_lm <-
          lm(data()$y ~ data()$x)
        beta_0 <-
          coef(fit_lm)[1] |> round(2)
        beta_1 <-
          coef(fit_lm)[2] |> round(2)
        
        withMathJax(
          paste0(
            "Regression Coefficients:"
            , "\\(\\beta_0 = ", beta_0, "\\)"
            , "; \\(\\beta_1 = ", beta_1, "\\)"
          )
        )
      }
      
    ))
  })
  
  
  data <-
    eventReactive(
      input$generateData,
      {
        new_slope = sample(-10:10, 1)
        new_intercept = sample(-20:20, 1)
        n = 1000
        x_dat = rnorm(n, 50, 15)
        y_dat = new_intercept + new_slope*x_dat + rnorm(n, 0, 25)
        
        list('x_dat' = x_dat, 'y_dat' = y_dat)
      }
    )

  output$summary_info <-
    renderUI(
      HTML(
        paste0(
          'x̄: ', mean(data()$x_dat) |> round(digits = 1)
          , '<br/>SS(x): ', sum((data()$x_dat - mean(data()$x_dat))^2) |> round(digits = 1)
          , '<br/>ȳ: ', mean(data()$y_dat) |> round(digits = 1)
          , '<br/>SS(y): ', sum((data()$y_dat - mean(data()$y_dat))^2) |> round(digits = 1)
        )
      )
    )
  
  output$summary_info2 <-
    renderUI(
      withMathJax(
        paste0('\\(\\Sigma_{i=1}^n (x_i - \\bar{x})(y_i - \\bar{y})\\): '
               , sum(
                 (data()$x_dat - mean(data()$x_dat)) * (data()$y_dat - mean(data()$y_dat))
               ) |> round(digits = 1)
        )
      )
    )

    output$distPlot <- 
        renderPlot({
          input$generateData
          plot(data()$x_dat, data()$y_dat, xlim = c(0,100), xlab = 'x', ylab = 'y')
          abline(a = input$y_intercept, b = input$x_slope, col = 'red')
        })
    
    output$sum_sq_error <-
      renderText(
        {
          prediction = (input$y_intercept + input$x_slope*data()$x_dat)
          error = data()$y_dat - prediction
          sumSquaredResiduals = sum(error^2)
          paste0(
            "Sum of Squared Errors: "
            , sumSquaredResiduals |> format(nsmall = 1, big.mark = ",")
          )  
        }
      )
      
    
}

# Run the application 
shinyApp(ui = ui, server = server)
