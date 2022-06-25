context("basic")
# This file is for testing application the in examples/recogito directory
# The recogito example application needs to be running on port 5448
# 
#   devtools::load_all() 
#   appDir = system.file(package="recogito","examples/recogito")
#   runApp(appDir,port=5448L)

library(RSelenium)
library(testthat)


rD <- rsDriver(browser="firefox",port=4545L,verbose=FALSE)
remDr <- rD[["client"]]
remDr$open(silent = TRUE)
appURL <- "http://127.0.0.1:5448"

test_that("recogito app running", {
  # Don't run these tests on CRAN build servers
  skip_on_cran()

  url = try(remDr$navigate(appURL))
  expect_equal(url,NULL)
  ## To start recogito app  
  ##   devtools::load_all() 
  ##   appDir = system.file(package="recogito","examples/recogito")
  ##   runApp(appDir,port=5448L)
})

test_that("tagging modal appears", {
  # Don't run these tests on CRAN build servers
  skip_on_cran()

  remDr$navigate(appURL)
  appTitle <- remDr$getTitle()[[1]]
  webElement = remDr$findElement(using="xpath",'//*[@id="annotation_text"]')
  remDr$mouseMoveToLocation(100,100,webElement)
  remDr$buttondown()
  remDr$mouseMoveToLocation(5,5)
  remDr$buttonup()
  Sys.sleep(2)
  remDr$buttonup()
  tagbox = remDr$findElement(using="xpath","/html/body/div/div/div/div[2]/div/div[2]/div[3]/button[1]")
  buttons = as.character(tagbox$getElementText())
  expect_equal(buttons, "Cancel")  
})

test_that("tagging annotations are created", {
  # Don't run these tests on CRAN build servers
  skip_on_cran()

  remDr$navigate(appURL)
  Sys.sleep(1)
  appTitle <- remDr$getTitle()[[1]]
  webElement = remDr$findElement(using="xpath",'//*[@id="annotation_text"]')
  remDr$mouseMoveToLocation(100,100,webElement)
  remDr$buttondown()
  remDr$mouseMoveToLocation(190,0)
  Sys.sleep(1)
  remDr$buttonup()
  Sys.sleep(2)
  remDr$buttonup()
  taginput = remDr$findElement(using="xpath","/html/body/div/div/div/div[2]/div/div[2]/div[2]/div/div/input")
  taginput$sendKeysToElement(list("qwerty_tag"))
  taginput$sendKeysToElement(list(key="enter"))
 
  tagcomment = remDr$findElement(using="xpath","/html/body/div/div/div/div[2]/div/div[2]/div[1]/textarea")
  tagcomment$sendKeysToElement(list("qwerty_comment"))
  tagcomment$sendKeysToElement(list(key="enter"))

  submit = remDr$findElement(using="xpath","/html/body/div/div/div/div[2]/div/div[2]/div[3]/button[2]")
  submit$clickElement()
  Sys.sleep(1)
  results = remDr$findElement(using="xpath",'//*[@id="annotation_result"]')
  parsed = results$getElementText()
  print(parsed)
  tagtext = grep("people",parsed[[1]])
  tagname = grep("qwerty_tag",parsed[[1]])
  tagcomment = grep("qwerty_c",parsed[[1]])
  results = paste(tagtext,tagname,tagcomment,collapse="") 
  expect_equal(results,"1 1 1")  
})

test_that("tagging annotations update", {
  # Don't run these tests on CRAN build servers
  skip_on_cran()
  remDr$navigate(appURL)
  Sys.sleep(1)
  appTitle <- remDr$getTitle()[[1]]
  webElement = remDr$findElement(using="xpath",'//*[@id="annotation_text"]')
  remDr$mouseMoveToLocation(100,100,webElement)
  Sys.sleep(1)
  remDr$buttondown()
  remDr$mouseMoveToLocation(190,0)
  remDr$buttonup()
  Sys.sleep(2)
  remDr$buttonup()
  taginput = remDr$findElement(using="xpath","/html/body/div/div/div/div[2]/div/div[2]/div[2]/div/div/input")
  taginput$sendKeysToElement(list("qwerty_tag"))
  taginput$sendKeysToElement(list(key="enter"))
 
  tagcomment = remDr$findElement(using="xpath","/html/body/div/div/div/div[2]/div/div[2]/div[1]/textarea")
  tagcomment$sendKeysToElement(list("qwerty_comment"))
  tagcomment$sendKeysToElement(list(key="enter"))

  submit = remDr$findElement(using="xpath","/html/body/div/div/div/div[2]/div/div[2]/div[3]/button[2]")
  submit$clickElement()
  Sys.sleep(1)
  results = remDr$findElement(using="xpath",'//*[@id="annotation_result"]')
  parsed = results$getElementText()
  tagtext = grep("people",parsed[[1]])
  tagname = grep("qwerty_tag",parsed[[1]])
  tagcomment = grep("qwerty_c",parsed[[1]])
  results1 = paste(tagtext,tagname,tagcomment,collapse="") 
  
  webElement = remDr$findElement(using="xpath",'//*[@id="annotation_text"]')
  remDr$mouseMoveToLocation(200,100,webElement)
  remDr$buttondown()
  remDr$buttonup()

  reply = "/html/body/div/div/div/div[2]/div/div[2]/div[2]/textarea"
  taglabel = remDr$findElement(using="xpath","/html/body/div/div/div/div[2]/div/div[2]/div[3]/ul/li")
  remDr$mouseMoveToLocation(0,0,taglabel)

  taglabel$click()

  tagdelete = remDr$findElement(using="xpath","/html/body/div/div/div/div[2]/div/div[2]/div[3]/ul/li/span[2]/span")
  remDr$mouseMoveToLocation(0,0,tagdelete)
  tagdelete$click()

  taginput = remDr$findElement(using="xpath","/html/body/div/div/div/div[2]/div/div[2]/div[3]/div/div/input")
  taginput$sendKeysToElement(list("nerdy_tag"))
  taginput$sendKeysToElement(list(key="enter"))

  okButton = remDr$findElement(using="xpath","/html/body/div/div/div/div[2]/div/div[2]/div[4]/button[3]")
  remDr$mouseMoveToLocation(0,0,okButton)
  okButton$click() 
  
  results = remDr$findElement(using="xpath",'//*[@id="annotation_result"]')
  parsed = results$getElementText()
  tagtext = grep("people",parsed[[1]])
  tagname = grep("nerdy_tag",parsed[[1]])
  tagcomment = grep("qwerty_c",parsed[[1]])
  results2 = paste(tagtext,tagname,tagcomment,collapse="") 
 
 
  expect_equal(results2,"1 1 1")  



})


remDr$close()
rD$server$stop()
