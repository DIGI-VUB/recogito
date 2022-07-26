#' @title Annotate images with areas of interest
#' @description Functionality to label areas in images
#' @param inputId character string with the name to use where annotations will be put into
#' @param src character string with the image/url to annotate
#' @param tags character vector of possible labels you want to use
#' @param type either \code{'annotorious'}, \code{'openseadragon'}, \code{'openseadragon-notoolbar'} in order to allow zooming with openseadragon or not, with or without a toolbar
#' @param quickselector logical indicating if for type \code{'openseadragon'} the possible tags should be shows as quick buttons to click. Defaults to \code{TRUE}.
#' @param width passed on to \code{\link[htmlwidgets]{createWidget}}
#' @param height passed on to \code{\link[htmlwidgets]{createWidget}}
#' @param elementId passed on to \code{\link[htmlwidgets]{createWidget}}
#' @param dependencies passed on to \code{\link[htmlwidgets]{createWidget}}
#' @return An object of class htmlwidget as returned by \code{\link[htmlwidgets]{createWidget}}
#' @seealso \code{\link{annotorious-shiny}}
#' @export
annotorious <- function(inputId = "annotations",
                        src,
                        tags = c(),
                        type = c("annotorious", "openseadragon", "openseadragon-notoolbar"),
                        quickselector = TRUE,
                        width = NULL, height = NULL, elementId = NULL, dependencies = NULL) {
  type <- match.arg(type)

  # forward options using x
  x = list(
    inputId = inputId,
    src = src,
    tags = tags,
    quickselector = quickselector,
    opts = list(type = type)
  )
  if(type %in% "annotorious"){
    htmlwidgets::createWidget(name = 'annotorious', x, width = width, height = height, package = 'recogito', elementId = elementId, dependencies = dependencies)
  }else if(type %in% "openseadragon"){
    htmlwidgets::createWidget(name = 'annotoriousopenseadragon', x, width = width, height = height, package = 'recogito', elementId = elementId, dependencies = dependencies)
  }else if(type %in% "openseadragon-notoolbar"){
    htmlwidgets::createWidget(name = 'annotoriousopenseadragonnotoolbar', x, width = width, height = height, package = 'recogito', elementId = elementId, dependencies = dependencies)
  }
}



widget_html.annotorious <- function(id, style, class, ...){
  el <- tags$div(
    id = sprintf("%s-outer-container", id),
    htmltools::tags$button(id = sprintf("%s-toggle", id), "RECTANGLE"),
    htmltools::tags$br(),
    htmltools::tags$br(),
    tags$div(
      id = id,
      class = class,
      htmltools::tags$img(id = sprintf("%s-img", id), src = "")
  ))
  el <- tags$div(
    tags$p(tags$div(id = sprintf("%s-outer-container", id))),
    tags$p(tags$div(id = id, class = class, style = style,
                    htmltools::tags$img(id = sprintf("%s-img", id)))))
  el
}

widget_html.annotoriousopenseadragon <- function(id, style, class, ...){
  el <- tags$div(
    tags$p(tags$div(id = sprintf("%s-outer-container", id))),
    tags$p(tags$div(id = id, class = class, style = style)))
  el
}

widget_html.annotoriousopenseadragonnotoolbar <- function(id, style, class, ...){
  el <- tags$div(tags$p(tags$div(id = id, class = class, style = style)))
  el
}

#' @title Shiny bindings for annotorious
#' @description Output and render functions for using annotorious within Shiny applications.
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a annotorious
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#' @name annotorious-shiny
#' @return An output element for use in a Shiny user interface.\cr
#' Consisting of a toggle button to switch between rectangle / polygon mode and
#' the html-widget (id: \code{outputId}) which contains an image (id: \code{outputId}\code{-img})
#' @export
#' @examples
#' if(interactive() && require(shiny)){
#' ##
#' ## Annotorious using OpenSeaDragon, allowing to zoom in,
#' ## to select an area, press shift and next select the area
#' ##
#' library(shiny)
#' library(recogito)
#' urls <- paste("https://upload.wikimedia.org/",
#'               c("wikipedia/commons/a/a0/Pamphlet_dutch_tulipomania_1637.jpg",
#'                 "wikipedia/commons/6/64/Cat_and_dog_standoff_%283926784260%29.jpg"),
#'               sep = "")
#' ui <- fluidPage(actionButton(inputId = "ui_switch", label = "Sample image"),
#'                 openseadragonOutput(outputId = "anno"),
#'                 tags$h3("Results"),
#'                 verbatimTextOutput(outputId = "annotation_result"))
#' server <- function(input, output) {
#'   current_image <- reactive({
#'     input$ui_switch
#'     list(url = sample(urls, size = 1))
#'   })
#'   output$anno <- renderOpenSeaDragon({
#'     info <- current_image()
#'     annotorious("annotations", tags = c("IMAGE", "TEXT"), src = info$url, type = "openseadragon")
#'   })
#'   output$annotation_result <- renderPrint({
#'     read_annotorious(input$annotations)
#'   })
#' }
#' shinyApp(ui, server)
#'
#' ##
#' ## Annotorious using OpenSeaDragon, allowing to zoom in, no selection possibilities
#' ## showing how to load a local image
#' ##
#' library(shiny)
#' library(recogito)
#' url <- system.file(package = "recogito", "examples", "Pamphlet_dutch_tulipomania_1637.jpg")
#' addResourcePath(prefix = "img", directoryPath = dirname(url))
#' ui <- fluidPage(openseadragonOutputNoToolbar(outputId = "anno", width = "100%", height = "250px"))
#' server <- function(input, output) {
#'   output$anno <- renderOpenSeaDragonNoToolbar({
#'     annotorious("annotations", src = sprintf("img/%s", basename(url)),
#'                  type = "openseadragon-notoolbar")
#'   })
#' }
#' shinyApp(ui, server)
#'
#' ##
#' ## Annotorious without openseadragon
#' ##
#' library(shiny)
#' library(recogito)
#' url <- paste("https://upload.wikimedia.org/",
#'              "wikipedia/commons/a/a0/Pamphlet_dutch_tulipomania_1637.jpg",
#'              sep = "")
#' ui <- fluidPage(annotoriousOutput(outputId = "anno", height = "600px"),
#'                 tags$h3("Results"),
#'                 verbatimTextOutput(outputId = "annotation_result"))
#' server <- function(input, output) {
#'   output$anno <- renderAnnotorious({
#'     annotorious("annotations", tags = c("IMAGE", "TEXT"), src = url, type = "annotorious")
#'   })
#'   output$annotation_result <- renderPrint({
#'     read_annotorious(input$annotations)
#'   })
#' }
#' shinyApp(ui, server)
#'
#' ##
#' ## Annotorious, without openseadragon changing the url
#' ##
#' library(shiny)
#' library(recogito)
#' urls <- paste("https://upload.wikimedia.org/",
#'               c("wikipedia/commons/a/a0/Pamphlet_dutch_tulipomania_1637.jpg",
#'                 "wikipedia/commons/6/64/Cat_and_dog_standoff_%283926784260%29.jpg"),
#'               sep = "")
#' ui <- fluidPage(actionButton(inputId = "ui_switch", label = "Sample image"),
#'                 annotoriousOutput(outputId = "anno", height = "600px"),
#'                 tags$h3("Results"),
#'                 verbatimTextOutput(outputId = "annotation_result"))
#' server <- function(input, output) {
#'   current_image <- reactive({
#'     input$ui_switch
#'     list(url = sample(urls, size = 1))
#'   })
#'   output$anno <- renderAnnotorious({
#'     info <- current_image()
#'     annotorious("annotations", tags = c("IMAGE", "TEXT"), src = info$url, type = "annotorious")
#'   })
#'   output$annotation_result <- renderPrint({
#'     read_annotorious(input$annotations)
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


#' @rdname annotorious-shiny
#' @export
openseadragonOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'annotoriousopenseadragon', width, height, package = 'recogito')
}

#' @rdname annotorious-shiny
#' @export
renderOpenSeaDragon <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, openseadragonOutput, env, quoted = TRUE)
}


#' @rdname annotorious-shiny
#' @export
openseadragonOutputNoToolbar <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'annotoriousopenseadragonnotoolbar', width, height, package = 'recogito')
}

#' @rdname annotorious-shiny
#' @export
renderOpenSeaDragonNoToolbar <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, openseadragonOutputNoToolbar, env, quoted = TRUE)
}




#' @title Parse annotorious annotations
#' @description Parse annotorious annotations
#' @param x a character string with json as returned by the htmlwidget
#' @param src a character string with the image src which was used in \code{x}
#' @export
#' @return a data.frame with annotations with columns: id, type, label, comment, x, y, width, height, polygon
#' and an attribute \code{src} with the provided \code{src}
#' @examples
#' url <- paste("https://upload.wikimedia.org/",
#'              "wikipedia/commons/a/a0/Pamphlet_dutch_tulipomania_1637.jpg",
#'              sep = "")
#' url <- system.file(package = "recogito", "examples", "Pamphlet_dutch_tulipomania_1637.jpg")
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
#' anno <- read_annotorious(x, src = url)
#' anno
#'
#' \dontshow{
#' if(require(magick))
#' \{
#' }
#' library(magick)
#' img  <- image_read(url)
#' area <- head(anno, n = 1)
#' image_crop(img, geometry_area(x = area$x, y = area$y,
#'                               width = area$width, height = area$height))
#' area <- subset(anno, type == "RECTANGLE")
#' allrectangles <- Map(
#'   x      = area$x,
#'   y      = area$y,
#'   width  = area$width,
#'   height = area$height,
#'   f = function(x, y, width, height){
#'     image_crop(img, geometry_area(x = x, y = y, width = width, height = height))
#' })
#' allrectangles <- do.call(c, allrectangles)
#' allrectangles
#' \dontshow{
#' \}
#' }
#'
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
#' anno <- read_annotorious(x, src = url)
#' anno
#' anno$polygon
#'
#' \dontshow{
#' if(require(opencv))
#' \{
#' }
#' library(opencv)
#' img  <- ocv_read(url)
#' area <- subset(anno, type == "POLYGON")
#' ocv_polygon(img, pts = area$polygon[[1]])
#' \dontshow{
#' \}
#' }
read_annotorious <- function(x, src = character()){
  default <- data.frame(id = character(), type = character(), label = I(list()), comment = I(list()), x = numeric(), y = numeric(), width = numeric(), height = numeric(), polygon = I(list()), stringsAsFactors = FALSE)
  if(is.character(x)){
    x <- jsonlite::fromJSON(x, simplifyVector = FALSE, simplifyDataFrame = FALSE, simplifyMatrix = FALSE, flatten = FALSE)
    if(length(x) == 0){
      out <- default
    }else{
      label   <- lapply(x, FUN = function(x) do.call(rbind, lapply(x$body, FUN=function(x) data.frame(value = x$value, purpose = x$purpose))))
      tags    <- lapply(label, FUN = function(x) x$value[x$purpose %in% "tagging"])
      comment <- lapply(label, FUN = function(x) x$value[x$purpose %in% "commenting"])
      x <- data.frame(id = sapply(x, FUN = function(x) x$id),
                      type = sapply(x, FUN = function(x){
                        x <- x$target$selector$value
                        ifelse(grepl(x, pattern = "xywh=pixel"), "RECTANGLE",
                               ifelse(grepl(x, pattern = "polygon points"), "POLYGON", NA))
                      }),
                      label = I(tags),
                      comment = I(comment),
                      content = sapply(x, FUN = function(x) x$target$selector$value), stringsAsFactors = FALSE)
      x$xywh <- strsplit(x$content, split = ":")
      x$xywh <- sapply(x$xywh, FUN = function(x) x[length(x)])
      x$xywh <- strsplit(x$xywh, split = ",")
      x$x <- NA_real_
      x$y <- NA_real_
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
      out <- x[, c("id", "type", "label", "comment", "x", "y", "width", "height", "polygon"), drop = FALSE]
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
    }

  }else{
    out <- default
  }
  out <- out[, c("id", "type", "label", "comment", "x", "y", "width", "height", "polygon"), drop = FALSE]
  attr(out, "src") <- src
  out
}
