#' @title Annotate images with areas of interest
#' @description Functionality to label areas in images
#' @param inputId The input slot that will be used to access the value
#' @param src character string with the image/url to annotate
#' @param tags character vector of possible tags
#' @param width passed on to \code{\link[htmlwidgets]{createWidget}}
#' @param height passed on to \code{\link[htmlwidgets]{createWidget}}
#' @param elementId passed on to \code{\link[htmlwidgets]{createWidget}}
#' @param dependencies passed on to \code{\link[htmlwidgets]{createWidget}}
#' @export
#' @examples
#' url <- "https://www.w3schools.com/images/picture.jpg"
#' annotorious(src = url)
#' url <- paste("https://nl.wikipedia.org/wiki/",
#'              "Hoofdpagina#/media/Bestand:Pamphlet_dutch_tulipomania_1637.jpg")
#' url <- paste("https://upload.wikimedia.org/",
#'              "wikipedia/commons/a/a0/Pamphlet_dutch_tulipomania_1637.jpg",
#'              sep = "")
#' annotorious(src = url)
annotorious <- function(inputId = "annotations",
                        src,
                        tags = c("Cat", "Dog", "Person", "Other"),
                        width = NULL, height = NULL, elementId = NULL, dependencies = NULL) {

  # forward options using x
  x = list(
    inputId = inputId,
    src = src,
    tags = tags
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'annotorious',
    x,
    width = width,
    height = height,
    package = 'recogito',
    elementId = elementId,
    dependencies = dependencies
  )
}




widget_html.annotorious <- function(id, style, class, ...){
  el <- tags$div(
    id = sprintf("%s-outer-container", id),
    htmltools::tags$button(id = sprintf("%s-toggle", id), "RECTANGLE"),
    #htmltools::tags$p(class="instructions", "Click and drag the mouse on the image to create a new area of annotation."),
    htmltools::tags$br(),
    htmltools::tags$br(),
    tags$div(
      id = id,
      class = class,
      #tags$img(id = "hallstatt", src="640px-Hallstatt.jpg")
      #htmltools::tags$img(id = sprintf("%s-img", id), src = "https://www.w3schools.com/images/picture.jpg")
      htmltools::tags$img(id = sprintf("%s-img", id))
  ))
  el
}

#' @title Shiny bindings for annotorious
#' @description Output and render functions for using annotorious within Shiny
#' applications and interactive Rmd documents.
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a annotorious
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#' @name annotorious-shiny
#' @export
#' @examples
#' if(interactive()){
#' library(shiny)
#' library(recogito)
#' url <- paste("https://upload.wikimedia.org/",
#'              "wikipedia/commons/a/a0/Pamphlet_dutch_tulipomania_1637.jpg",
#'              sep = "")
#' ui <- fluidPage(annotoriousOutput(outputId = "anno"),
#'                 tags$hr(),
#'                 tags$h3("Results"),
#'                 verbatimTextOutput(outputId = "annotation_result"))
#' server <- function(input, output) {
#'   output$anno <- renderAnnotorious({
#'     annotorious("annotations", tags = c("IMAGE", "TEXT"), src = url)
#'   })
#'   output$annotation_result <- renderPrint({
#'     read_annotorious_annotations(input$annotations)
#'   })
#' }
#' shinyApp(ui, server)
#'
#' }
annotoriousOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'annotorious', width, height, package = 'recogito')
}

#' @rdname annotorious-shiny
#' @export
renderAnnotorious <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, annotoriousOutput, env, quoted = TRUE)
}


#' @title Parse annotorious annotations
#' @description Parse annotorious annotations
#' @param x a character string with json as returned by the htmlwidget
#' @param src a character string with the image src which was used in \code{x}
#' @export
#' @examples
#' url <- paste("https://upload.wikimedia.org/",
#'              "wikipedia/commons/a/a0/Pamphlet_dutch_tulipomania_1637.jpg",
#'              sep = "")
#' x <- '[
#' {
#' "type":"Annotation",
#' "body":[{"type":"TextualBody","value":"IMAGE","purpose":"tagging"}],
#' "target":{"selector":{
#'   "type":"FragmentSelector",
#'   "conformsTo":"http://www.w3.org/TR/media-frags/",
#'   "value":"xywh=pixel:41,249.5234375,371,245"}},
#' "@context":"http://www.w3.org/ns/anno.jsonld",
#' "id":"#58f0096c-4675-4ea8-9f38-bffce0887ab8"
#' },
#' {
#' "type":"Annotation",
#' "body":[{"type":"TextualBody","value":"TEXT","purpose":"tagging"}],
#' "target":{"selector":{
#'   "type":"FragmentSelector",
#'   "conformsTo":"http://www.w3.org/TR/media-frags/",
#'   "value":"xywh=pixel:46,5.523437976837158,371,239.99999952316284"}},
#' "@context":"http://www.w3.org/ns/anno.jsonld",
#' "id":"#50035dda-c62b-4f30-bf95-1879d60288a5"}]'
#' anno <- read_annotorious_annotations(x, src = url)
#' anno
#'
#' x <- '[
#' {
#'   "type":"Annotation",
#'   "body":[{"type":"TextualBody","value":"IMAGE","purpose":"tagging"}],
#'   "target":{"selector":{
#'     "type":"FragmentSelector",
#'     "conformsTo":"http://www.w3.org/TR/media-frags/",
#'     "value":"xywh=pixel:43,244.5234375,362,252"
#'     }},
#'  "@context":"http://www.w3.org/ns/anno.jsonld",
#'  "id":"#4eaa8788-0c7e-42d2-b004-4d66b57018a1"},
#' {
#'   "type":"Annotation",
#'   "body":[{"type":"TextualBody","value":"TEXT","purpose":"tagging"}],
#'   "target":{"selector":{
#'     "type":"SvgSelector",
#'     "value":"<svg>
#'     <polygon points=\\\"75,4 75,58 32,95 32,194 410,195 391,70 373,63 368,3 222,1.5\\\">
#'     </polygon></svg>"}},
#'   "@context":"http://www.w3.org/ns/anno.jsonld",
#'   "id":"#8bf0a557-c847-4a07-91bc-68a98c499615"}]'
#' x    <- gsub(x, pattern = "\n", replacement = "")
#' anno <- read_annotorious_annotations(x, src = url)
#' anno
#' anno$polygon
read_annotorious_annotations <- function(x, src = character()){
  if(is.character(x)){
    x <- jsonlite::fromJSON(x, simplifyVector = FALSE, simplifyDataFrame = FALSE, simplifyMatrix = FALSE, flatten = FALSE)
    x <- data.frame(id = sapply(x, FUN = function(x) x$id),
                    type = sapply(x, FUN = function(x){
                      x <- x$target[[1]]$value
                      ifelse(grepl(x, pattern = "xywh=pixel"), "RECTANGLE",
                             ifelse(grepl(x, pattern = "polygon points"), "POLYGON", NA))
                    }),
                    label = sapply(x, FUN = function(x) x$body[[1]]$value),
                    content = sapply(x, FUN = function(x) x$target[[1]]$value), stringsAsFactors = FALSE)
    x$xywh <- strsplit(x$content, split = ":")
    x$xywh <- sapply(x$xywh, FUN = function(x) x[length(x)])
    x$xywh <- strsplit(x$xywh, split = ",")
    x$x <- NA_real_
    x$u <- NA_real_
    x$width <- NA_real_
    x$height <- NA_real_
    idx <- which(x$type == "RECTANGLE")
    x$x[idx]       <- as.numeric(sapply(x$xywh[idx], FUN = function(x) x[1]))
    x$y[idx]       <- as.numeric(sapply(x$xywh[idx], FUN = function(x) x[2]))
    x$width[idx]   <- as.numeric(sapply(x$xywh[idx], FUN = function(x) x[3]))
    x$height[idx]  <- as.numeric(sapply(x$xywh[idx], FUN = function(x) x[4]))
    idx <- which(x$type == "POLYGON")
    x$polygon      <- NA_character_
    if(length(idx) > 0){
      x$polygon[idx] <- sapply(strsplit(x$content[idx], split = '"'), FUN = function(x) x[2])
    }
    out <- x[, c("id", "type", "label", "x", "y", "width", "height", "polygon"), drop = FALSE]
    out$polygon <- strsplit(out$polygon, split = " ")
    out$polygon <- lapply(out$polygon, FUN = function(x){
      if(all(is.na(x))){
        x <- data.frame(x = numeric(), y = numeric())
      }else{
        x <- strsplit(x, split = ",")
        x <- data.frame(x = as.numeric(sapply(x, FUN = function(x) x[1])),
                        y = as.numeric(sapply(x, FUN = function(x) x[2])))
      }
      x
    })
  }else{
    out <- data.frame(id = character(), type = character(), label = character(), x = numeric(), y = numeric(), width = numeric(), height = numeric(), polygon = list(), stringsAsFactors = FALSE)
  }
  out <- out[, c("id", "type", "label", "x", "y", "width", "height", "polygon"), drop = FALSE]
  attr(out, "src") <- src
  out
}
