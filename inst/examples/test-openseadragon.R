library(shiny)
library(recogito)
url <- "https://upload.wikimedia.org/wikipedia/commons/a/a0/Pamphlet_dutch_tulipomania_1637.jpg"
url <- "https://iiif.ghentcdh.ugent.be/iiif/images/getuigenissen:brugse_vrije:RABrugge_I15_16999_V02:RABrugge_I15_16999_V02_01/full/full/0/default.jpg"
ui <- fluidPage(openseadragonOutput(outputId = "anno"),
                tags$hr(),
                tags$h3("Results"),
                verbatimTextOutput(outputId = "annotation_result"))
server <- function(input, output) {
  output$anno <- renderOpenSeaDragon({
    annotorious("annotations", tags = c("IMAGE", "TEXT"), src = url, type = "openseadragon")
  })
  output$annotation_result <- renderPrint({
    read_annotorious(input$annotations)
  })
}
shinyApp(ui, server)
