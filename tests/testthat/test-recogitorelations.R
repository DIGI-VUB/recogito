context("recogitorelations")
# This file is for testing application the in examples/recogito directory
# The recogito example application needs to be running on port 5447
#
#   devtools::load_all()
#   appDir = system.file(package="recogito","examples/recogito")
#   runApp(appDir,port=5447L)

library(RSelenium)
library(testthat)


## XPATHs for elements used during testing

LOAD_ANNOTATION <- '//*[@id="loadannotation"]'
LOADED_ANNOTATION <- '//*[@id="annotation_text"]/span[2]' 
NEXT_TEXT <- '//*[@id="nexttext"]'
ANNOTATION_TEXT <- '//*[@id="annotation_text"]'
ANNOTATION_RESULT <- '//*[@id="annotation_result"]'
MODAL_CANCEL <- "/html/body/div/div/div/div/div[2]/div/div[2]/div[3]/button[1]"
MODAL_OK <- "/html/body/div/div/div/div/div[2]/div/div[2]/div[3]/button[2]"
TAG_INPUT <- "/html/body/div/div/div/div/div[2]/div/div[2]/div[2]/div/div/input"
TAG_COMMENT <- "/html/body/div/div/div/div/div[2]/div/div[2]/div[1]/textarea"
TAG_REPLY <- "/html/body/div/div/div/div/div[2]/div/div[2]/div[2]/textarea" 
TAG_INPUT2 <- '//*[@id="downshift-18-input"]'
UPDATE_MODAL_OK <-   "/html/body/div/div/div/div/div[2]/div/div[2]/div[4]/button[3]"
UPDATE_TAG_LABEL <-  "/html/body/div/div/div/div/div[2]/div/div[2]/div[3]/ul/li"
UPDATE_TAG_DELETE <- "/html/body/div/div/div/div//div[2]/div/div[2]/div[3]/ul/li/span[2]/span"
UPDATE_TAG_INPUT <-  "/html/body/div/div/div//div/div[2]/div/div[2]/div[3]/div/div/input"
TOGGLE_BUTTON <- '//*[@id="annotationmode"]'
RELATION_TAG <- '//*[@id="downshift-30-input"]'
PREDEFINED_RELATION_TAG <-'/html/body/div/div/div/div/div[2]/div/div[1]/div/ul/li'
## In version 1.7.1 of recogito-js these tags changed 
RELATION_TAG_171 <- "/html/body/div/div/div/div/div[2]/div/div[1]/div/div/input"
TAG_INPUT2_171 <-   "/html/body/div/div/div/div/div[2]/div/div[2]/div[2]/div/div/input"

WRAPPER<-'/html/body/div/div/div'

rD <- rsDriver(browser = "firefox", port = 4545L, verbose = FALSE)

remDr <<- rD[["client"]]
remDr$open(silent = TRUE)
remDr$setWindowSize(1028, 1028, winHand = "current") 
appURL <- "http://127.0.0.1:5447"

# Wait until body of page is loaded or element is found
waiting <- function(sleepmin, sleepmax, xpath = NULL) {
  remDr <- get("remDr", envir = globalenv())
  webElemtest <- NULL
  iter = 0 
  while (is.null(webElemtest) & iter < 300) {
    iter = iter + 1
    if (is.null(xpath)) {
      webElemtest <- tryCatch(
        {
          remDr$findElement(using = "css", "body")
        },
        error = function(e) {
          NULL
        }
      )
    } else {
      webElemtest <- tryCatch(
        {
          remDr$findElement(using = "xpath", xpath)
        },
        error = function(e) {
          NULL
        }
      )
    }
    # loop until element with name <value> is found in <webpage url>
  }
  randsleep <- sample(seq(sleepmin, sleepmax, by = 0.001), 1)
  Sys.sleep(randsleep)
}

test_that("recogito app running", {
  # Don't run these tests on CRAN build servers
  skip_on_cran()

  url <- try(remDr$navigate(appURL))
  expect_equal(url, NULL)
  # To start recogito app
  #   devtools::load_all()
  #   appDir = system.file(package="recogito","examples/recogito")
  #   runApp(appDir,port=5448L)
})

test_that("tagging modal appears", {
  # Don't run these tests on CRAN build servers
  skip_on_cran()

  remDr$setWindowSize(1028, 1028, winHand = "current") 
  remDr$navigate(appURL)
  waiting(0.1, 0.5)
  appTitle <- remDr$getTitle()[[1]]
  remDr$setWindowSize(1028, 1028, winHand = "current") 
  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)
  remDr$mouseMoveToLocation(100, 100, webElement)
  remDr$buttondown()
  remDr$mouseMoveToLocation(5, 5)
  remDr$buttonup()
  waiting(0.1, 0.5, MODAL_CANCEL)
  tagbox <- remDr$findElement(using = "xpath", MODAL_CANCEL)
  buttons <- as.character(tagbox$getElementText())
  expect_equal(buttons, "Cancel")
})

test_that("tagging annotations are created", {
  # Don't run these tests on CRAN build servers
  skip_on_cran()

  remDr$setWindowSize(1028, 1028, winHand = "current") 
  remDr$navigate(appURL)
  waiting(0.1, 0.5)
  appTitle <- remDr$getTitle()[[1]]
  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)
  waiting(0.1, 0.5, ANNOTATION_TEXT)
  remDr$mouseMoveToLocation(100, 100, webElement)
  remDr$buttondown()
  remDr$mouseMoveToLocation(190, 0)
  remDr$buttonup()
  waiting(0.1, 0.5, TAG_INPUT)
  taginput <- remDr$findElement(using = "xpath", TAG_INPUT)
  taginput$sendKeysToElement(list("qwerty_tag"))
  taginput$sendKeysToElement(list(key = "enter"))

  tagcomment <- remDr$findElement(using = "xpath", TAG_COMMENT)
  tagcomment$sendKeysToElement(list("qwerty_comment"))
  tagcomment$sendKeysToElement(list(key = "enter"))

  submit <- remDr$findElement(using = "xpath", MODAL_OK)
  submit$clickElement()
  waiting(0.1, 0.5, ANNOTATION_RESULT)
  results <- remDr$findElement(using = "xpath", ANNOTATION_RESULT)
  parsed <- results$getElementText()
  tagtext <- grep("people", parsed[[1]])
  tagname <- grep("qwerty_tag", parsed[[1]])
  tagcomment <- grep("qwerty_c", parsed[[1]])
  results <- paste(tagtext, tagname, tagcomment, collapse = "")
  expect_equal(results, "1 1 1")
})

test_that("tagging annotations update", {
  # Don't run these tests on CRAN build servers
  skip_on_cran()
  remDr$setWindowSize(1028, 1028, winHand = "current") 
  remDr$navigate(appURL)
  waiting(0.1, 0.5)
  appTitle <- remDr$getTitle()[[1]]
  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)
  waiting(0.1, 0.5, ANNOTATION_TEXT)
  remDr$mouseMoveToLocation(100, 100, webElement)
  remDr$buttondown()
  remDr$mouseMoveToLocation(190, 0)
  remDr$buttonup()
  waiting(0.1, 0.5, TAG_INPUT)
  taginput <- remDr$findElement(using = "xpath", TAG_INPUT)
  taginput$sendKeysToElement(list("qwerty_tag"))
  taginput$sendKeysToElement(list(key = "enter"))
  tagcomment <- remDr$findElement(using = "xpath", TAG_COMMENT)
  tagcomment$sendKeysToElement(list("qwerty_comment"))
  tagcomment$sendKeysToElement(list(key = "enter"))

  submit <- remDr$findElement(using = "xpath", MODAL_OK)
  submit$clickElement()
  waiting(0.1, 0.5, ANNOTATION_RESULT)
  results <- remDr$findElement(using = "xpath", ANNOTATION_RESULT)
  parsed <- results$getElementText()
  tagtext <- grep("people", parsed[[1]])
  tagname <- grep("qwerty_tag", parsed[[1]])
  tagcomment <- grep("qwerty_c", parsed[[1]])
  results1 <- paste(tagtext, tagname, tagcomment, collapse = "")

  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)
  remDr$mouseMoveToLocation(200, 100, webElement)
  remDr$buttondown()
  remDr$buttonup()

  waiting(0.1, 0.5, TAG_REPLY)
  taglabel <- remDr$findElement(using = "xpath", UPDATE_TAG_LABEL)
  remDr$mouseMoveToLocation(0, 0, taglabel)

  taglabel$click()

  waiting(0.1, 0.5, UPDATE_TAG_DELETE)
  tagdelete <- remDr$findElement(using = "xpath", UPDATE_TAG_DELETE)
  remDr$mouseMoveToLocation(0, 0, tagdelete)
  tagdelete$click()

  taginput <- remDr$findElement(using = "xpath", UPDATE_TAG_INPUT)
  taginput$sendKeysToElement(list("nerdy_tag"))
  taginput$sendKeysToElement(list(key = "enter"))

  okButton <- remDr$findElement(using = "xpath", UPDATE_MODAL_OK)
  remDr$mouseMoveToLocation(0, 0, okButton)
  okButton$click()

  waiting(0.1, 0.5, ANNOTATION_RESULT)
  results <- remDr$findElement(using = "xpath", ANNOTATION_RESULT)
  parsed <- results$getElementText()
  tagtext <- grep("people", parsed[[1]])
  tagname <- grep("nerdy_tag", parsed[[1]])
  tagcomment <- grep("qwerty_c", parsed[[1]])
  results2 <- paste(tagtext, tagname, tagcomment, collapse = "")


  expect_equal(results2, "1 1 1")
})

test_that("relations are created", {
  # Don't run these tests on CRAN build servers
  skip_on_cran()
  
  remDr$setWindowSize(1028, 1028, winHand = "current") 
  remDr$navigate(appURL)
  waiting(0.1, 0.5)
  appTitle <- remDr$getTitle()[[1]]
  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)

  ## Creating First Tag
  waiting(0.1, 0.5, ANNOTATION_TEXT)
  remDr$mouseMoveToLocation(100, 100, webElement)
  remDr$buttondown()
  remDr$mouseMoveToLocation(190, 0)
  remDr$buttonup()
  waiting(0.1, 0.5, TAG_INPUT)
  taginput <- remDr$findElement(using = "xpath", TAG_INPUT)
  taginput$sendKeysToElement(list("qwerty_tag"))
  taginput$sendKeysToElement(list(key = "enter"))

  tagcomment <- remDr$findElement(using = "xpath", TAG_COMMENT)
  tagcomment$sendKeysToElement(list("qwerty_comment"))
  tagcomment$sendKeysToElement(list(key = "enter"))

  submit <- remDr$findElement(using = "xpath", MODAL_OK)
  submit$clickElement()

  ## Creating Second Tag
  waiting(0.1, 0.5, ANNOTATION_TEXT)
  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)
  waiting(0.1, 0.5, ANNOTATION_TEXT)
  remDr$mouseMoveToLocation(-150, -100, webElement)
  remDr$buttondown()
  remDr$mouseMoveToLocation(-190, 0)
  remDr$buttonup()
  waiting(0.1, 0.5, TAG_INPUT2_171)
  taginput <- remDr$findElement(using = "xpath", TAG_INPUT2_171)
  taginput$sendKeysToElement(list("nerdy_tag"))
  taginput$sendKeysToElement(list(key = "enter"))

  submit <- remDr$findElement(using = "xpath", MODAL_OK)
  submit$clickElement()
  waiting(0.1, 0.5, ANNOTATION_RESULT)

  ## Change to Relations Mode
  togglebutton <- remDr$findElement(using = "xpath", TOGGLE_BUTTON)
  togglebutton$clickElement()

  ## Link Tag1 & Tag2
  waiting(0.1, 0.5, ANNOTATION_TEXT)
  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)
  waiting(0.1, 0.5, ANNOTATION_TEXT)
  remDr$mouseMoveToLocation(-150, -100, webElement)
  remDr$buttondown()
  remDr$buttonup()

  waiting(0.1, 0.5, ANNOTATION_TEXT)
  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)
  waiting(0.1, 0.5, ANNOTATION_TEXT)
  remDr$mouseMoveToLocation(150, 100, webElement)
  remDr$buttondown()
  remDr$buttonup()

  relationtag <- remDr$findElement(using = "xpath", RELATION_TAG_171)
  relationtag$sendKeysToElement(list("isLinked"))
  relationtag$sendKeysToElement(list(key = "enter"))


  results <- remDr$findElement(using = "xpath", ANNOTATION_RESULT)
  parsed <- results$getElementText()
  tag1 <- grep("nerdy", parsed[[1]])
  tag2 <- grep("qwerty", parsed[[1]])
  link <- grep("isLinked", parsed[[1]])
  results <- paste(tag1, tag2, link, collapse = "")
  expect_equal(results, "1 1 1")
})

test_that("predefined relation tags are created", {
  # Don't run these tests on CRAN build servers
  skip_on_cran()

  remDr$setWindowSize(1028, 1028, winHand = "current") 
  remDr$navigate(appURL)
  waiting(0.1, 0.5)
  appTitle <- remDr$getTitle()[[1]]
  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)

  ## Creating First Tag
  waiting(0.1, 0.5, ANNOTATION_TEXT)
  remDr$mouseMoveToLocation(100, 100, webElement)
  remDr$buttondown()
  remDr$mouseMoveToLocation(190, 0)
  remDr$buttonup()
  waiting(0.1, 0.5, TAG_INPUT)
  taginput <- remDr$findElement(using = "xpath", TAG_INPUT)
  taginput$sendKeysToElement(list("qwerty_tag"))
  taginput$sendKeysToElement(list(key = "enter"))

  tagcomment <- remDr$findElement(using = "xpath", TAG_COMMENT)
  tagcomment$sendKeysToElement(list("qwerty_comment"))
  tagcomment$sendKeysToElement(list(key = "enter"))

  submit <- remDr$findElement(using = "xpath", MODAL_OK)
  submit$clickElement()

  ## Creating Second Tag
  waiting(0.1, 0.5, ANNOTATION_TEXT)
  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)
  waiting(0.1, 0.5, ANNOTATION_TEXT)
  remDr$mouseMoveToLocation(-150, -100, webElement)
  remDr$buttondown()
  remDr$mouseMoveToLocation(-190, 0)
  remDr$buttonup()
  waiting(0.1, 0.5, TAG_INPUT2_171)
  taginput <- remDr$findElement(using = "xpath", TAG_INPUT2_171)
  taginput$sendKeysToElement(list("nerdy_tag"))
  taginput$sendKeysToElement(list(key = "enter"))

  submit <- remDr$findElement(using = "xpath", MODAL_OK)
  submit$clickElement()
  waiting(0.1, 0.5, ANNOTATION_RESULT)

  ## Change to Relations Mode
  togglebutton <- remDr$findElement(using = "xpath", TOGGLE_BUTTON)
  togglebutton$clickElement()

  ## Link Tag1 & Tag2
  waiting(0.1, 0.5, ANNOTATION_TEXT)
  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)
  waiting(0.1, 0.5, ANNOTATION_TEXT)
  remDr$mouseMoveToLocation(-150, -100, webElement)
  remDr$buttondown()
  remDr$buttonup()

  waiting(0.1, 0.5, ANNOTATION_TEXT)
  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)
  waiting(0.1, 0.5, ANNOTATION_TEXT)
  remDr$mouseMoveToLocation(150, 100, webElement)
  remDr$buttondown()
  remDr$buttonup()

  relationtag <- remDr$findElement(using = "xpath", RELATION_TAG_171)
  relationtag$sendKeysToElement(list("isLin"))
  waiting(0.1, 0.5, PREDEFINED_RELATION_TAG)
  ptag = remDr$findElement(using="xpath",PREDEFINED_RELATION_TAG)
  tagtext = as.character(ptag$getElementText())
 
  expect_equal(tagtext, "isLinked")
})


test_that("tagging annotations cleared after update", {
  
  remDr$setWindowSize(1028, 1028, winHand = "current") 
  remDr$navigate(appURL)
  waiting(0.1, 0.5)
  appTitle <- remDr$getTitle()[[1]]
  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)

  ## Get cleared results 
  waiting(0.1, 0.5,ANNOTATION_RESULT)
  results <- remDr$findElement(using = "xpath", ANNOTATION_RESULT)
  parsed <- results$getElementText()
  initialResults = parsed[[1]]
 
  waiting(0.1, 0.5, ANNOTATION_TEXT)
  remDr$mouseMoveToLocation(100, 100, webElement)
  remDr$buttondown()
  remDr$mouseMoveToLocation(190, 0)
  remDr$buttonup()
  waiting(0.1, 0.5, TAG_INPUT)
  taginput <- remDr$findElement(using = "xpath", TAG_INPUT)
  taginput$sendKeysToElement(list("qwerty_tag"))
  taginput$sendKeysToElement(list(key = "enter"))

  tagcomment <- remDr$findElement(using = "xpath", TAG_COMMENT)
  tagcomment$sendKeysToElement(list("qwerty_comment"))
  tagcomment$sendKeysToElement(list(key = "enter"))

  submit <- remDr$findElement(using = "xpath", MODAL_OK)
  submit$clickElement()
  waiting(0.1, 0.5, ANNOTATION_RESULT)
  results <- remDr$findElement(using = "xpath", ANNOTATION_RESULT)
  parsed <- results$getElementText()
  tagtext <- grep("people", parsed[[1]])
  tagname <- grep("qwerty_tag", parsed[[1]])
  tagcomment <- grep("qwerty_c", parsed[[1]])
  results1 <- paste(tagtext, tagname, tagcomment, collapse = "")

  nextText <- remDr$findElement(using="xpath",NEXT_TEXT)
  nextText$clickElement()
  results <- remDr$findElement(using = "xpath", ANNOTATION_RESULT)
  parsed <- results$getElementText()
  finalResults = parsed[[1]]
  
  expect_equal(initialResults,finalResults)
})


test_that("content wrappers aren't nested", {
  # Don't run these tests on CRAN build servers
  # Make sure sending data to recogito doesn't result 
  # in nested DOM objects being created 
  skip_on_cran()

  remDr$setWindowSize(1028, 1028, winHand = "current") 
  remDr$navigate(appURL)
  waiting(0.1, 0.5)
  appTitle <- remDr$getTitle()[[1]]
  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)
  waiting(1, 1, ANNOTATION_TEXT)
  wrappers = remDr$findElements(using="css",".r6o-content-wrapper")
  initialLength = length(wrappers)
  
  nextText <- remDr$findElement(using="xpath",NEXT_TEXT)
  nextText$clickElement()
  
  nextText <- remDr$findElement(using="xpath",NEXT_TEXT)
  nextText$clickElement()
  
  nextText <- remDr$findElement(using="xpath",NEXT_TEXT)
  nextText$clickElement()

  wrappers = remDr$findElements(using="css",".r6o-content-wrapper")
  finalLength = length(wrappers)

  expect_equal(initialLength,finalLength)
})


test_that("tagging annotations modal opened only once after text is update", {
  ## createAnnotation and updateAnnotation events are only bound once to 
  ## the annotation_text events. Check that you only have to click "cancel" 
  ## once to make the update tag modal close  
  remDr$setWindowSize(1028, 1028, winHand = "current") 
  remDr$navigate(appURL)
  waiting(0.1, 0.5)
  appTitle <- remDr$getTitle()[[1]]
  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)
  waiting(0.1, 0.5, ANNOTATION_TEXT)
 
  ## Check How Many Buttons Are present when creating tag  

  ## Create a tag 
  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)
  waiting(0.1, 0.5, ANNOTATION_TEXT)
  remDr$mouseMoveToLocation(100, 100, webElement)
  remDr$buttondown()
  remDr$mouseMoveToLocation(190, 0)
  remDr$buttonup()

  waiting(0.1, 0.5, TAG_INPUT2_171)
  taginput <- remDr$findElement(using = "xpath", TAG_INPUT)
  taginput$sendKeysToElement(list("qwerty_tag"))
  taginput$sendKeysToElement(list(key = "enter"))

  tagcomment <- remDr$findElement(using = "xpath", TAG_COMMENT)
  tagcomment$sendKeysToElement(list("qwerty_comment"))
  tagcomment$sendKeysToElement(list(key = "enter"))
  
  buttons <- remDr$findElements(using="css",".r6o-btn")
  initialButtons = length(buttons)
  ## Click each button 
  indx = c()
 
  while(length(buttons) > 0){
  for(i in 1:length(buttons)){
   if(buttons[[i]]$getElementText()=="Ok"){
     indx = c(indx,i)
   }
  }

  for(i in indx){
    buttons[[i]]$clickElement()
  }
  buttons <- remDr$findElements(using="css",".r60-btn")
  }
  

  nextText <- remDr$findElement(using="xpath",NEXT_TEXT)
  nextText$clickElement()

  nextText <- remDr$findElement(using="xpath",NEXT_TEXT)
  nextText$clickElement()
  
  nextText <- remDr$findElement(using="xpath",NEXT_TEXT)
  nextText$clickElement()

  nextText <- remDr$findElement(using="xpath",NEXT_TEXT)
  nextText$clickElement()

  ## Create a tag 
  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)
  waiting(0.1, 0.5, ANNOTATION_TEXT)
  remDr$mouseMoveToLocation(100, 100, webElement)
  remDr$buttondown()
  remDr$mouseMoveToLocation(190, 0)
  remDr$buttonup()

  waiting(0.1, 0.5, TAG_INPUT2_171)
  taginput <- remDr$findElement(using = "xpath", TAG_INPUT)
  taginput$sendKeysToElement(list("qwerty_tag"))
  taginput$sendKeysToElement(list(key = "enter"))

  tagcomment <- remDr$findElement(using = "xpath", TAG_COMMENT)
  tagcomment$sendKeysToElement(list("qwerty_comment"))
  tagcomment$sendKeysToElement(list(key = "enter"))

  ## Check How many buttons are present 
  buttons <- remDr$findElements(using="css",".r6o-btn")
  finalButtons = length(buttons)
  indx = c()
 
  while(length(buttons) > 0){
  for(i in 1:length(buttons)){
   if(buttons[[i]]$getElementText()=="Ok"){
     indx = c(indx,i)
   }
  }

  for(i in indx){
    buttons[[i]]$clickElement()
  }
  buttons <- remDr$findElements(using="css",".r60-btn")
  }
  expect_equal(initialButtons,finalButtons)
})

test_that("tagging relations created after text is updated", {
  # Don't run these tests on CRAN build servers
  skip_on_cran()

  remDr$setWindowSize(1028, 1028, winHand = "current") 
  remDr$navigate(appURL)
  waiting(0.1, 0.5)
  appTitle <- remDr$getTitle()[[1]]
  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)
  
  nextText <- remDr$findElement(using="xpath",NEXT_TEXT)
  nextText$clickElement()
  
  nextText <- remDr$findElement(using="xpath",NEXT_TEXT)
  nextText$clickElement()
  
  nextText <- remDr$findElement(using="xpath",NEXT_TEXT)
  nextText$clickElement()


  ## Creating First Tag
  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)
  waiting(1, 1, ANNOTATION_TEXT)
  remDr$mouseMoveToLocation(100, 100, webElement)
  remDr$buttondown()
  remDr$mouseMoveToLocation(190, 0)
  waiting(0.1,0.5)
  remDr$buttonup()
  waiting(0.1, 0.5, TAG_INPUT)
  taginput <- remDr$findElement(using = "xpath", TAG_INPUT)
  taginput$sendKeysToElement(list("qwerty_tag"))
  taginput$sendKeysToElement(list(key = "enter"))

  tagcomment <- remDr$findElement(using = "xpath", TAG_COMMENT)
  tagcomment$sendKeysToElement(list("qwerty_comment"))
  tagcomment$sendKeysToElement(list(key = "enter"))

  submit <- remDr$findElement(using = "xpath", MODAL_OK)
  submit$clickElement()

  ## Creating Second Tag
  waiting(0.1, 0.5, ANNOTATION_TEXT)
  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)
  waiting(1, 1, ANNOTATION_TEXT)
  remDr$mouseMoveToLocation(-150, -100, webElement)
  remDr$buttondown()
  remDr$mouseMoveToLocation(-190, 0)
  waiting(0.1,0.5)
  remDr$buttonup()
  waiting(0.1, 0.5, TAG_INPUT2_171)
  taginput <- remDr$findElement(using = "xpath", TAG_INPUT2_171)
  taginput$sendKeysToElement(list("nerdy_tag"))
  taginput$sendKeysToElement(list(key = "enter"))

  submit <- remDr$findElement(using = "xpath", MODAL_OK)
  submit$clickElement()
  waiting(0.1, 0.5, ANNOTATION_RESULT)

  ## Change to Relations Mode
  togglebutton <- remDr$findElement(using = "xpath", TOGGLE_BUTTON)
  togglebutton$clickElement()

  ## Link Tag1 & Tag2
  waiting(0.1, 0.5, ANNOTATION_TEXT)
  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)
  waiting(0.1, 0.5, ANNOTATION_TEXT)
  remDr$mouseMoveToLocation(-150, -100, webElement)
  remDr$buttondown()
  remDr$buttonup()

  waiting(0.1, 0.5, ANNOTATION_TEXT)
  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)
  waiting(0.1, 0.5, ANNOTATION_TEXT)
  remDr$mouseMoveToLocation(150, 100, webElement)
  remDr$buttondown()
  remDr$buttonup()
  
  waiting(0.1, 0.5, RELATION_TAG_171)
  relationtag <- remDr$findElement(using = "xpath", RELATION_TAG_171)
  relationtag$sendKeysToElement(list("isLinked"))
  relationtag$sendKeysToElement(list(key = "enter"))

  results <- remDr$findElement(using = "xpath", ANNOTATION_RESULT)
  parsed <- results$getElementText()
  tag1 <- grep("nerdy", parsed[[1]])
  tag2 <- grep("qwerty", parsed[[1]])
  link <- grep("isLinked", parsed[[1]])
  results <- paste(tag1, tag2, link, collapse = "")
  expect_equal(results, "1 1 1")
})

test_that("annotations are loaded", {
  # Don't run these tests on CRAN build servers
  skip_on_cran()

  remDr$setWindowSize(1028, 1028, winHand = "current") 
  remDr$navigate(appURL)
  waiting(0.1, 0.5)
  appTitle <- remDr$getTitle()[[1]]
  webElement <- remDr$findElement(using = "xpath", ANNOTATION_TEXT)
  loadButton <- remDr$findElement(using = "xpath", LOAD_ANNOTATION) 
  loadButton$clickElement()
  waiting(0.1,0.5,LOADED_ANNOTATION) 
   
  annotation = remDr$findElement(using = "xpath", LOADED_ANNOTATION)
  results = as.character(annotation$getElementText())

  expect_equal(results, "er he h")
})



remDr$close()
rD$server$stop()
