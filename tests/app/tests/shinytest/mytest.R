app <- ShinyDriver$new("../../")
app$snapshotInit("mytest")

app$setInputs(name = "jpbida")
app$setInputs(greet = "click")
app$snapshot()
