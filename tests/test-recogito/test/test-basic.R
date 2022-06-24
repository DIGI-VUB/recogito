context("basic")

library(RSelenium)
library(testthat)

rD <- rsDriver(browser="phantomjs")
remDr <- rD[["client"]]
remDr$open(silent = TRUE)
appURL <- "http://127.0.0.1:5448"

test_that("tagging modal appears", {  
  remDr$navigate(appURL)
  appTitle <- remDr$getTitle()[[1]]
  remDr$mouseMoveToLocation(100,100)
  remDr$buttondown()
  remDr$mouseMoveToLocation(5,5)
  remDr$buttonup()
  Sys.sleep(2)
  remDr$buttonup()
  tagbox = remDr$findElement(using="xpath","/html/body/div/div/div/div[2]/div/div[2]/div[3]/button[1]")
  buttons = as.character(tagbox$getElementText())
  expect_equal(buttons, "Cancel")  
})


remDr$close()
rD$server$stop()
