

txt       <- "Josh went to the bakery in Brussels.\nWhat an adventure!"

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
                recogitotagsonlyOutput(outputId = "annotation_text"),
                tags$hr(),
                tags$h3("Results"),
                verbatimTextOutput(outputId = "annotation_result"))

server <- function(input, output) {
  output$annotation_text <- renderRecogitotagsonly({
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
