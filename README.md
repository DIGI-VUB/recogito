# recogito

Annotate text with your tags / Annotate areas of interests in images with your own labels

- This repository contains an R package which provides a [htmlwidget](https://www.htmlwidgets.org) library for [recogito-js](https://github.com/recogito/recogito-js) and  [annotorious](https://github.com/recogito/annotorious).
- The package allows to annotate text using **tags and relations between these tags**. 
    - A common use case is for entity labelling and entity linking
- Next you can use the package to **annotate areas of interest (rectangles / polygons) in images** with specific labels
    - Handy for quick data preparation of images

### Example on Image Annotation

![](tools/example-annotorious-shiny.gif)

```r
library(shiny)
library(recogito)
url <- "https://upload.wikimedia.org/wikipedia/commons/a/a0/Pamphlet_dutch_tulipomania_1637.jpg"
ui  <- fluidPage(annotoriousOutput(outputId = "anno"),
                 tags$hr(),
                 tags$h3("Results"),
                 verbatimTextOutput(outputId = "annotation_result"))
server <- function(input, output) {
  output$anno <- renderAnnotorious({
    annotorious("results", tags = c("IMAGE", "TEXT"), src = url)
  })
  output$annotation_result <- renderPrint({
    read_annotorious(input$results)
  })
}
shinyApp(ui, server)
```

### Example on Text Annotation

> Simple example in RStudio

![](tools/example-recogito-basic.png)

```r
library(recogito)
txt <- "Josh went to the bakery in Brussels.\nWhat an adventure!"
x   <- recogito(text = txt)
x
```

> Example with Shiny

![](tools/example-recogito-shiny.gif)

> With the following code

```r
library(shiny)
library(recogito)
txt <- "Tell me, O muse, of that ingenious hero who travelled far and wide after he had sacked
the famous town of Troy. Many cities did he visit, and many were the nations with whose manners and customs
he was acquainted; moreover he suffered much by sea while trying to save his own life and bring his men safely
home; but do what he might he could not save his men, for they perished through their own sheer folly in eating
the cattle of the Sun-god Hyperion; so the god prevented them from ever reaching home. Tell me, too, about all
these things, O daughter of Jove, from whatsoever source you may know them.\n
So now all who escaped death in battle or by shipwreck had got safely home except Ulysses,
and he, though he was longing to return to his wife and country, was detained by the goddess Calypso, who
had got him into a large cave and wanted to marry him. But as years went by, there came a time when the gods
settled that he should go back to Ithaca; even then, however, when he was among his own people, his troubles
were not yet over; nevertheless all the gods had now begun to pity him except Neptune, who still persecuted
him without ceasing and would not let him get home."

tagset    <- c("LOCATION", "TIME", "PERSON")
tagstyles <- "
.tag-PERSON {
color:red;
}
.tag-LOCATION {
background-color:green;
}
.tag-TIME {
font-weight: bold;
}
"
ui <- fluidPage(tags$head(tags$style(HTML(tagstyles))),
                tags$br(),
                recogitoOutput(outputId = "annotation_text"),
                tags$hr(),
                tags$h3("Results"),
                verbatimTextOutput(outputId = "annotation_result"))

server <- function(input, output) {
  output$annotation_text <- renderRecogito({
    recogito("annotations", text = txt, tags = tagset)
  })
  output$annotation_result <- renderPrint({
    if(length(input$annotations) > 0){
      x <- read_recogito(input$annotations)
      x
    }
  })
}
shinyApp(ui, server)
```

### Installation

- For regular users, install the package from your local CRAN mirror `install.packages("recogito")`
- For installing the development version of this package: `remotes::install_github("DIGI-VUB/recogito")`

Look to documentation of the functions

```
help(package = "recogito")
```


### DIGI

By DIGI: Brussels Platform for Digital Humanities: https://digi.research.vub.be

![](tools/logo.png)
