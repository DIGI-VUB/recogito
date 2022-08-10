library(shiny)
library(recogito)
library(udpipe)
data(brussels_reviews, package = "udpipe")
texts <- data.frame(doc_id = brussels_reviews$id,
                    text = brussels_reviews$feedback,
                    stringsAsFactors = FALSE)

ui <- fluidPage(
  titlePanel("Example"),
  sidebarLayout(
    sidebarPanel(
      actionButton(inputId = "ui_next", label = "Next"),
      textOutput(outputId = "uo_doc_id")
    ),
    mainPanel(
      recogitoOutput(outputId = "annotation_text"),
      tags$h3("Results"),
      verbatimTextOutput(outputId = "annotation_result")
    )
  )
)



server <- function(input, output) {
  current_text <- reactiveValues(i = 1, data = head(texts, n = 1))
  observeEvent(input$ui_next, {
    current_text$i    <- current_text$i + 1
    current_text$data <- texts[current_text$i, ]
  })
  output$uo_doc_id <- renderText({
    current_text$data$doc_id
  })
  output$annotation_text <- renderRecogito({
    print(current_text$data$text)
    recogito(inputId = "annotations", text = current_text$data$text, tags = c("LOCATION", "TIME", "PERSON"))
  })
  output$annotation_result <- renderPrint({
    read_recogito(input$annotations)
  })
}
shinyApp(ui, server)




library(shiny)
library(recogito)
data(brussels_reviews, package = "udpipe")
texts <- data.frame(doc_id = brussels_reviews$id,
                    text = brussels_reviews$feedback,
                    stringsAsFactors = FALSE)

ui <- fluidPage(
  tags$br(),
  actionButton(inputId = "ui_next", label = "Next"),
  tags$hr(),
  recogitotagsonlyOutput(outputId = "annotation_text"),
  tags$hr(),
  tags$h3("Results"),
  verbatimTextOutput(outputId = "annotation_result"))
server <- function(input, output) {
  current_text <- reactiveValues(id = 0,
                                 text = "Hello there, here is some text to annotate\nCan you identify the locations, persons and timepoints.\nJosh went to the bakery in Brussels.\nWhat an adventure!")
  observeEvent(input$ui_next, {
    ## Put here your save calls (as in save to a database or file or API)
    ## Go to the next text
    i <- sample(seq_len(nrow(texts)), size = 1)
    current_text$id   <- texts$doc_id[i]
    current_text$text <- texts$text[i]
  })
  output$annotation_text <- renderRecogito({
    recogito("annotations", text = current_text$text, tags = c("LOCATION", "TIME", "PERSON"), type = "tags")
  })
  output$annotation_result <- renderPrint(read_recogito(input$annotations))
}
shinyApp(ui, server)




library(shiny)
library(recogito)
data(brussels_reviews, package = "udpipe")
texts <- data.frame(doc_id = brussels_reviews$id,
                    text = brussels_reviews$feedback,
                    stringsAsFactors = FALSE)

ui <- fluidPage(
  tags$br(),
  actionButton(inputId = "ui_next", label = "Next"),
  tags$hr(),
  recogitoOutput(outputId = "annotation_text"),
  tags$hr(),
  tags$h3("Results"),
  verbatimTextOutput(outputId = "annotation_result"))
server <- function(input, output) {
  current_text <- reactiveValues(id = 0,
                                 text = "Hello there, here is some text to annotate\nCan you identify the locations, persons and timepoints.\nJosh went to the bakery in Brussels.\nWhat an adventure!")
  observeEvent(input$ui_next, {
    ## Put here your save calls (as in save to a database or file or API)
    ## Go to the next text
    i <- sample(seq_len(nrow(texts)), size = 1)
    current_text$id   <- texts$doc_id[i]
    current_text$text <- texts$text[i]
  })
  output$annotation_text <- renderRecogito({
    recogito("annotations", text = current_text$text, tags = c("LOCATION", "TIME", "PERSON"), type = "relations")
  })
  output$annotation_result <- renderPrint(read_recogito(input$annotations))
}
shinyApp(ui, server)
