library(shiny)
library(recogito)
url <- "https://upload.wikimedia.org/wikipedia/commons/a/a0/Pamphlet_dutch_tulipomania_1637.jpg"

ui <- fluidPage(annotoriousOutput(outputId = "anno"),
                tags$hr(),
                tags$h3("Results"),
                verbatimTextOutput(outputId = "annotation_result"))
server <- function(input, output) {
  output$anno <- renderAnnotorious({
    annotorious("annotations", tags = c("IMAGE", "TEXT"), src = url)
  })
  output$annotation_result <- renderPrint({
    read_annotorious(input$annotations)
  })
}
shinyApp(ui, server)


if(FALSE){
  library(jsonlite)
  x <- "[{\"type\":\"Annotation\",\"body\":[{\"type\":\"TextualBody\",\"value\":\"IMAGE\",\"purpose\":\"tagging\"},{\"type\":\"TextualBody\",\"value\":\"TEXT\",\"purpose\":\"tagging\"},{\"type\":\"TextualBody\",\"value\":\"sdfsdfsd\",\"purpose\":\"commenting\"}],\"target\":{\"selector\":{\"type\":\"FragmentSelector\",\"conformsTo\":\"http://www.w3.org/TR/media-frags/\",\"value\":\"xywh=pixel:43,243.5234375,369,255\"}},\"@context\":\"http://www.w3.org/ns/anno.jsonld\",\"id\":\"#5b4efb39-6f5f-4828-be22-4e678aa985e1\"},{\"type\":\"Annotation\",\"body\":[{\"type\":\"TextualBody\",\"value\":\"TEXT\",\"purpose\":\"tagging\"},{\"type\":\"TextualBody\",\"value\":\"waw\",\"purpose\":\"commenting\"}],\"target\":{\"selector\":{\"type\":\"SvgSelector\",\"value\":\"<svg><polygon points=\\\"73,8.523438453674316 27,199.5234375 410,208.5234375 405,4.523437976837158\\\"></polygon></svg>\"}},\"@context\":\"http://www.w3.org/ns/anno.jsonld\",\"id\":\"#a20ea257-4a31-40af-b95e-99f4c6e438a2\"}]"
  x <- "[{\"type\":\"Annotation\",\"body\":[{\"type\":\"TextualBody\",\"value\":\"IMAGE\",\"purpose\":\"tagging\"}],\"target\":{\"selector\":{\"type\":\"FragmentSelector\",\"conformsTo\":\"http://www.w3.org/TR/media-frags/\",\"value\":\"xywh=pixel:41,249.5234375,371,245\"}},\"@context\":\"http://www.w3.org/ns/anno.jsonld\",\"id\":\"#58f0096c-4675-4ea8-9f38-bffce0887ab8\"},{\"type\":\"Annotation\",\"body\":[{\"type\":\"TextualBody\",\"value\":\"TEXT\",\"purpose\":\"tagging\"}],\"target\":{\"selector\":{\"type\":\"FragmentSelector\",\"conformsTo\":\"http://www.w3.org/TR/media-frags/\",\"value\":\"xywh=pixel:46,5.523437976837158,371,239.99999952316284\"}},\"@context\":\"http://www.w3.org/ns/anno.jsonld\",\"id\":\"#50035dda-c62b-4f30-bf95-1879d60288a5\"}]"
  x <- "[{\"type\":\"Annotation\",\"body\":[{\"type\":\"TextualBody\",\"value\":\"IMAGE\",\"purpose\":\"tagging\"}],\"target\":{\"selector\":{\"type\":\"FragmentSelector\",\"conformsTo\":\"http://www.w3.org/TR/media-frags/\",\"value\":\"xywh=pixel:43,244.5234375,362,252\"}},\"@context\":\"http://www.w3.org/ns/anno.jsonld\",\"id\":\"#4eaa8788-0c7e-42d2-b004-4d66b57018a1\"},{\"type\":\"Annotation\",\"body\":[{\"type\":\"TextualBody\",\"value\":\"TEXT\",\"purpose\":\"tagging\"}],\"target\":{\"selector\":{\"type\":\"SvgSelector\",\"value\":\"<svg><polygon points=\\\"75,4.523437976837158 75,58.5234375 32,95.5234375 32,194.5234375 410,195.5234375 391,70.5234375 373,63.5234375 368,3.5234382152557373 222,1.5234380960464478\\\"></polygon></svg>\"}},\"@context\":\"http://www.w3.org/ns/anno.jsonld\",\"id\":\"#8bf0a557-c847-4a07-91bc-68a98c499615\"}]"

  x <- fromJSON(x, simplifyVector = FALSE, simplifyDataFrame = FALSE, simplifyMatrix = FALSE, flatten = FALSE)
  x <- data.frame(id = sapply(x, FUN = function(x) x$id),
                  label = sapply(x, FUN = function(x) x$body[[1]]$value),
                  xywh = sapply(x, FUN = function(x) x$target[[1]]$value), stringsAsFactors = FALSE)
  x$xywh <- strsplit(x$xywh, split = ":")
  x$xywh <- sapply(x$xywh, FUN = tail, n = 1)
  x$xywh <- strsplit(x$xywh, split = ",")
  x$x <- as.numeric(sapply(x$xywh, FUN = function(x) x[1]))
  x$y <- as.numeric(sapply(x$xywh, FUN = function(x) x[2]))
  x$width <- as.numeric(sapply(x$xywh, FUN = function(x) x[3]))
  x$height <- as.numeric(sapply(x$xywh, FUN = function(x) x[4]))
  x <- x[, c("", "", "", "", "")]

  library(magick)
  url <- "https://upload.wikimedia.org/wikipedia/commons/a/a0/Pamphlet_dutch_tulipomania_1637.jpg"
  img <- image_read(url)
  x <- head(x, 1)
  x <- tail(x, 1)
  image_crop(img, geometry_area(x = x$x, y = x$y, width = x$width, height = x$height))
  image_crop(img, geometry_area(x = x$x, y = x$y, width = x$width, height = x$height))
}
