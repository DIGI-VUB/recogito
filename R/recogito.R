#' @title Annotate text with tags and relations
#' @description Functionality to tag text with entities and relations between these
#' @param inputId character string with the name to use where annotations will be put into
#' @param text character string with the text to annotate
#' @param type either 'relations' or 'tags' in order to label relations between tags or only plain tags
#' @param tags character vector of possible tags
#' @param mode either 'html' or 'pre'
#' @param annotations character string with a predefined set of annotations
#' @param width passed on to \code{\link[htmlwidgets]{createWidget}}
#' @param height passed on to \code{\link[htmlwidgets]{createWidget}}
#' @param elementId passed on to \code{\link[htmlwidgets]{createWidget}}
#' @param dependencies passed on to \code{\link[htmlwidgets]{createWidget}}
#' @return An object of class htmlwidget as returned by \code{\link[htmlwidgets]{createWidget}}
#' @seealso \code{\link{recogito-shiny}}
#' @export
#' @examples
#' txt <- "Josh went to the bakery in Brussels.\nWhat an adventure!"
#' x   <- recogito(inputId = "annotations", txt)
#' x
#' x   <- recogito(inputId = "annotations", txt, type = "tags",
#'                 tags = c("LOCATION", "TIME", "PERSON"))
#' x
#' txt <- "Lorem ipsum dolor sit amet consectetur adipiscing elit Quisque tellus urna
#'   placerat in tortor ac imperdiet sollicitudin mi Integer vel dolor mollis feugiat
#'   sem eu porttitor elit Sed aliquam urna sed placerat euismod In risus sem ornare
#'   nec malesuada eu ornare quis dui Nunc finibus fermentum sollicitudin Fusce vel
#'   imperdiet mi ac faucibus leo Cras massa massa ultricies et justo vitae molestie
#'   auctor turpis Vestibulum euismod porta risus euismod dapibus Nullam facilisis
#'   ipsum sed est tempor et aliquam sapien auctor Aliquam velit ligula convallis a
#'   dui id varius bibendum quam Cras malesuada nec justo sed
#'   aliquet Fusce urna magna malesuada"
#' x   <- recogito(inputId = "annotations", txt)
#' x
#' x   <- recogito(inputId = "annotations", txt, type = "tags",
#'                 tags = c("LOCATION", "TIME", "PERSON", "OTHER"))
#' x
#'
#' ##
#' ## Color the tags by specifying CSS - they should have .tag-{TAGLABEL}
#' ##
#' library(htmltools)
#' cat(readLines(system.file(package = "recogito", "examples", "example.css")), sep = "\n")
#' tagsetcss <- htmlDependency(name = "mytagset", version = "1.0",
#'                             src = system.file(package = "recogito", "examples"),
#'                             stylesheet = "example.css")
#' x   <- recogito(inputId = "annotations", txt,
#'                 tags = c("LOCATION", "TIME", "PERSON", "OTHER"),
#'                 dependencies = tagsetcss)
#' x
recogito <- function(inputId = "annotations",
                     text,
                     type = c("relations", "tags"),
                     tags = c("Location", "Person", "Place", "Other"),
                     mode = c("html", "pre"),
                     annotations = "{}", width = NULL, height = NULL, elementId = NULL, dependencies = NULL) {
  type <- match.arg(type)
  mode <- match.arg(mode)
  x <- list(inputId = inputId, text = text, tags = tags, type = type,
            #path = tempfile(pattern = "annotations_", fileext = ".json"),
            mode = mode, annotations = annotations)
  if(type == "relations"){
    htmlwidgets::createWidget(name = 'recogito', x,
                              width = width, height = height, package = 'recogito', elementId = elementId, dependencies = dependencies)
  }else{
    htmlwidgets::createWidget(name = 'recogitotagsonly', x,
                              width = width, height = height, package = 'recogito', elementId = elementId, dependencies = dependencies)
  }

}


widget_html.recogito <- function(id, style, class, ...){
  el <- htmltools::tags$div(
    id = sprintf("%s-outer-container", id), style = "position:relative;",
    htmltools::tags$div(
      id = sprintf("%s-content", id), class = "plaintext", style = "max-width:920px;font-family:'Lato', sans-serif;font-size:17px;line-height:27px;",
      htmltools::tags$button(id = sprintf("%s-toggle", id), "MODE: ANNOTATION"),
      #tags$button(id = "toggle-mode", "MODE: ANNOTATION"),
      htmltools::tags$hr(),
      htmltools::tags$div(id = id, class = class)
    )
  )
  el
}

widget_html.recogitotagsonly <- function(id, style, class, ...){
  el <- htmltools::tags$div(
    id = "outer-container", style = "position:relative;",
    htmltools::tags$div(
      id = sprintf("%s-content", id), class = "plaintext", style = "max-width:920px;font-family:'Lato', sans-serif;font-size:17px;line-height:27px;",
      htmltools::tags$div(id = id, class = class)
    )
  )
  el
}







#' @title Shiny bindings for recogito
#' @description Output and render functions for using recogito within Shiny
#' applications and interactive Rmd documents.
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a recogito
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#' @name recogito-shiny
#' @return An output element for use in a Shiny user interface.\cr
#' Consisting of a div of class plaintext which contains an optional toggle button to switch
#' between annotation / relation mode (id: \code{outputId}\code{-toggle}) and
#' the html-widget (id: \code{outputId})
#' @export
#' @examples
#' if(interactive() && require(shiny)){
#'
#' ##
#' ## Tagging only, no relations
#' ##
#' library(shiny)
#' library(recogito)
#' txt <- "Josh went to the bakery in Brussels.\nWhat an adventure!"
#' ui <- fluidPage(tags$h3("Provide some text to annotate"),
#'                 textAreaInput(inputId = "ui_text", label = "Provide some text", value = txt),
#'                 tags$h3("Annotation area"),
#'                 recogitotagsonlyOutput(outputId = "annotation_text"),
#'                 tags$hr(),
#'                 tags$h3("Results"),
#'                 verbatimTextOutput(outputId = "annotation_result"))
#' server <- function(input, output) {
#'   output$annotation_text <- renderRecogitotagsonly({
#'     recogito("annotations", text = input$ui_text, tags = c("LOCATION", "TIME", "PERSON"))
#'   })
#'   output$annotation_result <- renderPrint({
#'     read_recogito(input$annotations)
#'   })
#' }
#' shinyApp(ui, server)
#'
#' ##
#' ## Tagging and relations
#' ##
#' library(shiny)
#' library(recogito)
#' txt <- "Josh went to the bakery in Brussels.\nWhat an adventure!"
#' ui <- fluidPage(tags$h3("Provide some text to annotate"),
#'                 textAreaInput(inputId = "ui_text", label = "Provide some text", value = txt),
#'                 tags$h3("Annotation area"),
#'                 recogitoOutput(outputId = "annotation_text"),
#'                 tags$hr(),
#'                 tags$h3("Results"),
#'                 verbatimTextOutput(outputId = "annotation_result"))
#' server <- function(input, output) {
#'   output$annotation_text <- renderRecogito({
#'     recogito("annotations", text = input$ui_text, tags = c("LOCATION", "TIME", "PERSON"))
#'   })
#'   output$annotation_result <- renderPrint({
#'     read_recogito(input$annotations)
#'   })
#' }
#' shinyApp(ui, server)
#'
#' }
#'
#' recogitoOutput(outputId = "annotation_text")
#' recogitotagsonlyOutput(outputId = "annotation_text")
recogitoOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, name = 'recogito', width, height, package = 'recogito')
}


#' @rdname recogito-shiny
#' @export
renderRecogito <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, recogitoOutput, env, quoted = TRUE)
}


#' @rdname recogito-shiny
#' @export
recogitotagsonlyOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, name = 'recogitotagsonly', width, height, package = 'recogito')
}

#' @rdname recogito-shiny
#' @export
renderRecogitotagsonly <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, recogitotagsonlyOutput, env, quoted = TRUE)
}



#' @title Parse recogito annotations
#' @description Parse recogito annotations
#' @param x a character string with json as returned by the htmlwidget
#' @param text a character string with the text which was used in \code{x}
#' @return a data.frame with annotations with columns: id, type, label, chunk_text, chunk_start, chunk_end, relation_from, relation_to, chunk_comment
#' and an attribute \code{text} with the provided \code{text}
#' @export
#' @examples
#' x <- '[
#' {
#' "type":"Annotation",
#' "body":[
#'    {"type":"TextualBody","value":"sdfsd","purpose":"commenting"},
#'    {"type":"TextualBody","value":"Person","purpose":"tagging"}],
#' "target":{"selector":[
#'   {"type":"TextQuoteSelector","exact":"ngenious hero"},
#'   {"type":"TextPositionSelector","start":42,"end":55}]},
#' "@context":"http://www.w3.org/ns/anno.jsonld",
#' "id":"#a4ea53d4-69f3-4392-a3dd-cbb7e9ad50cb"
#' },
#' {
#' "type":"Annotation",
#' "body":[{"type":"TextualBody","value":"Person","purpose":"tagging"},
#'   {"type":"TextualBody","value":"Location","purpose":"tagging"}],
#' "target":{"selector":[{"type":"TextQuoteSelector","exact":"far and"},
#'   {"type":"TextPositionSelector","start":70,"end":77}]},
#' "@context":"http://www.w3.org/ns/anno.jsonld",
#' "id":"#d7050196-2537-42bf-9d1b-a3f9e4c9fbc6"
#' }
#' ]'
#' read_recogito(x)
read_recogito <- function(x, text = character()){
  default <- data.frame(id = character(), type = character(), chunk_text = character(), chunk_start = integer(), chunk_end = integer(), relation_from = character(), relation_to = character(), stringsAsFactors = FALSE)
  default$label         <- list()
  default$chunk_comment <- list()
  if(is.character(x)){
    x       <- jsonlite::fromJSON(x, simplifyVector = FALSE, simplifyDataFrame = FALSE, simplifyMatrix = FALSE, flatten = FALSE)
    if(length(x) == 0){
      out <- default
    }else{
      label   <- lapply(x, FUN = function(x) do.call(rbind, lapply(x$body, FUN=function(x) data.frame(value = x$value, purpose = x$purpose))))
      target  <- lapply(x, FUN = function(x){
        data <- x$target
        if("selector" %in% names(data)){
          data <- data.frame(chunk_text = data$selector[[1]]$exact, chunk_start = data$selector[[2]]$start, chunk_end = data$selector[[2]]$end, relation_from = NA_character_, relation_to = NA_character_, stringsAsFactors = FALSE)
        }else{
          data <- unlist(data, recursive = TRUE, use.names = FALSE)
          data <- data.frame(chunk_text = NA_character_, chunk_start = NA_integer_, chunk_end = NA_integer_, relation_from = data[1], relation_to = data[2], stringsAsFactors = FALSE)
        }
        data
      })
      tags    <- lapply(label, FUN = function(x) x$value[x$purpose %in% "tagging"])
      comment <- lapply(label, FUN = function(x) x$value[x$purpose %in% "commenting"])
      out <- data.frame(id      = sapply(x, FUN = function(x) x$id),
                        type    = sapply(target, FUN=function(x) ifelse(is.na(x$relation_from), "TAG", "RELATION")),
                        chunk_text    = sapply(target, FUN=function(x) x$chunk_text),
                        chunk_start   = sapply(target, FUN=function(x) x$chunk_start),
                        chunk_end     = sapply(target, FUN=function(x) x$chunk_end),
                        relation_from = sapply(target, FUN=function(x) x$relation_from),
                        relation_to   = sapply(target, FUN=function(x) x$relation_to),
                        stringsAsFactors = FALSE)
      out$label   <- I(tags)
      out$chunk_comment <- I(comment)
    }
    out
  }else{
    out <- default
  }
  out <- out[, c("id", "type", "label", "chunk_text", "chunk_start", "chunk_end", "relation_from", "relation_to", "chunk_comment"), drop = FALSE]
  attr(out, "text") <- text
  out
}

at_least_na <- function(x){
  if(length(x) == 0){
    x <- NA_character_
  }
  x
}
# na_exclude <- function(x, default = NA){
#   x <- x[!is.na(x)]
#   if(length(x) == 0){
#     x <- default
#   }
#   x
# }
