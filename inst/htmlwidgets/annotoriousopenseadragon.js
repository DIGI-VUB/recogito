HTMLWidgets.widget({
  name: 'annotoriousopenseadragon',
  type: 'output',
  factory: function(el, width, height) {
    console.log(document.getElementById(el.id.concat("-img")));
    console.log(el.id);
    var viewer = OpenSeadragon({
          //id: "openseadragon",
          id: el.id,
          prefixUrl: "/openseadragon-2.4.2/images/",
/*
          tileSources: {
            type: "image",
            //url: "https://upload.wikimedia.org/wikipedia/commons/8/82/%22CUT%22_June_1929_05.jpg"
            url: "https://upload.wikimedia.org/wikipedia/commons/a/a0/Pamphlet_dutch_tulipomania_1637.jpg"
            //url: document.getElementById(el.id.concat("-img")).src
          },
*/
          gestureSettingsTouch: {
            pinchRotate: true
          },
          showRotationControl: false,
          showFlipControl: false,
          constrainDuringPan: true,
        });
    return {
      renderValue: function(x) {
        viewer.open({
            type: "image",
            //url: "https://upload.wikimedia.org/wikipedia/commons/a/a0/Pamphlet_dutch_tulipomania_1637.jpg"
            //url: "https://upload.wikimedia.org/wikipedia/commons/8/82/%22CUT%22_June_1929_05.jpg"
            url: x.src
          });
        var anno = OpenSeadragon.Annotorious(viewer, {
          image: el.id,
          locale: 'auto',
          allowEmpty: true,
          widgets: [
            { widget: 'COMMENT' },
            { widget: 'TAG', vocabulary: x.tags }
          ],
          formatter: Annotorious.ShapeLabelsFormatter()
        });
        if(x.opts.type === "openseadragon"){
          Annotorious.Toolbar(anno, document.getElementById(el.id.concat("-outer-container")));
          Annotorious.BetterPolygon(anno);
        }
        anno.on('createAnnotation', function(a) {
          Shiny.setInputValue(x.inputId, JSON.stringify(anno.getAnnotations()));
        });
        anno.on('updateAnnotation', function(a) {
          Shiny.setInputValue(x.inputId, JSON.stringify(anno.getAnnotations()));
        });
        anno.on('deleteAnnotation', function(a) {
          Shiny.setInputValue(x.inputId, JSON.stringify(anno.getAnnotations()));
        });
      },
      resize: function(width, height) {
      }

    };
  }
});
