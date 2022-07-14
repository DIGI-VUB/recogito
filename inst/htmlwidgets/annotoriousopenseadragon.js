HTMLWidgets.widget({
  name: 'annotoriousopenseadragon',
  type: 'output',
  factory: function(el, width, height) {
    var viewer = OpenSeadragon({
      id: el.id,
      prefixUrl: "/openseadragon-2.4.2/images/",
      gestureSettingsTouch: {
        pinchRotate: true
      },
      showRotationControl: false,
      showFlipControl: false,
      constrainDuringPan: true,
    });
    var anno = OpenSeadragon.Annotorious(viewer, {
      image: el.id,
      locale: 'auto',
      allowEmpty: true,
      formatter: Annotorious.ShapeLabelsFormatter()
    });
    Annotorious.Toolbar(anno, document.getElementById(el.id.concat("-outer-container")));
    Annotorious.BetterPolygon(anno);
    return {
      renderValue: function(x) {
        anno.widgets = [
            { widget: 'COMMENT' },
            { widget: 'TAG', vocabulary: x.tags }
          ];
        anno.clearAnnotations();
        Shiny.setInputValue(x.inputId, JSON.stringify(anno.getAnnotations()));
        viewer.open({
            type: "image",
            url: x.src
          });
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
