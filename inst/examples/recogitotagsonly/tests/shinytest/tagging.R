library("base")
app <- ShinyDriver$new("../../")
app$snapshotInit("tagging")

app$executeScript(
'
move = $.Event(\'mousemove\');
moveover = $.Event(\'mousemove\');
down = $.Event(\'mousedown\');
up = $.Event(\'mouseup\');

// coordinates
move.pageX = 100;
move.pageY = 100; 
moveover.pageX = 300;
moveover.pageY = 100; 

$(document).trigger(move);
$(document).trigger(down);
$(document).trigger(moveover);
$(document).trigger(up);
'
)
Sys.sleep(3)

app$snapshot()
