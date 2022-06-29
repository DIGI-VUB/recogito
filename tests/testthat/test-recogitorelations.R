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

ANNOTATION_TEXT <- '//*[@id="annotation_text"]'
ANNOTATION_RESULT <- '//*[@id="annotation_result"]'
MODAL_CANCEL <- "/html/body/div/div/div/div[2]/div/div[2]/div[3]/button[1]"
MODAL_OK <- "/html/body/div/div/div/div[2]/div/div[2]/div[3]/button[2]"
TAG_INPUT <- "/html/body/div/div/div/div[2]/div/div[2]/div[2]/div/div/input"
TAG_COMMENT <- "/html/body/div/div/div/div[2]/div/div[2]/div[1]/textarea"
TAG_REPLY <- "/html/body/div/div/div/div[2]/div/div[2]/div[2]/textarea"
TAG_INPUT2 <- '//*[@id="downshift-18-input"]'
UPDATE_MODAL_OK <- "/html/body/div/div/div/div[2]/div/div[2]/div[4]/button[3]"
UPDATE_TAG_LABEL <- "/html/body/div/div/div/div[2]/div/div[2]/div[3]/ul/li"
UPDATE_TAG_DELETE <- "/html/body/div/div/div/div[2]/div/div[2]/div[3]/ul/li/span[2]/span"
UPDATE_TAG_INPUT <- "/html/body/div/div/div/div[2]/div/div[2]/div[3]/div/div/input"
TOGGLE_BUTTON <- '//*[@id="annotation_text-toggle"]'
RELATION_TAG <- '//*[@id="downshift-30-input"]'
## In version 1.7.1 of recogito-js these tags changed 
RELATION_TAG_171 <- "/html/body/div/div/div/div[2]/div/div[1]/div/div/input"
TAG_INPUT2_171 <-"/html/body/div/div/div/div[2]/div/div[2]/div[2]/div/div/input"


rD <- rsDriver(browser = "firefox", port = 4545L, verbose = FALSE)
remDr <<- rD[["client"]]
remDr$open(silent = TRUE)
appURL <- "http://127.0.0.1:5447"

# Wait until body of page is loaded or element is found
waiting <- function(sleepmin, sleepmax, xpath = NULL) {
  remDr <- get("remDr", envir = globalenv())
  webElemtest <- NULL
  while (is.null(webElemtest)) {
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

  remDr$navigate(appURL)
  waiting(0.1, 0.5)
  appTitle <- remDr$getTitle()[[1]]
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



remDr$close()
rD$server$stop()
