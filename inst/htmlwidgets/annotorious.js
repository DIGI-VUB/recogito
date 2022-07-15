HTMLWidgets.widget({
  name: 'annotorious',
  type: 'output',
  factory: function(el, width, height) {
    anno = Annotorious.init({
      image: el.id,
      locale: 'auto',
      formatter: Annotorious.ShapeLabelsFormatter()
    });
    return {
      renderValue: function(x) {
        anno.widgets = [
            { widget: 'COMMENT' },
            { widget: 'TAG', vocabulary: x.tags }
          ];
        anno.clearAnnotations();
        Shiny.setInputValue(x.inputId, JSON.stringify(anno.getAnnotations()));
        document.getElementById(el.id.concat("-img")).src = x.src;
        anno.on('createAnnotation', function(a) {
          Shiny.setInputValue(x.inputId, JSON.stringify(anno.getAnnotations()));
        });
        anno.on('updateAnnotation', function(a) {
          Shiny.setInputValue(x.inputId, JSON.stringify(anno.getAnnotations()));
        });
        anno.on('deleteAnnotation', function(a) {
          Shiny.setInputValue(x.inputId, JSON.stringify(anno.getAnnotations()));
        });
        // Rectangle / Polygon
        anno.setDrawingTool('rect');
        var toggleModeBtn = document.getElementById(el.id.concat("-toggle"));
        toggleModeBtn.addEventListener('click', function() {
          annotationMode = toggleModeBtn.innerHTML;
          if (annotationMode === 'RECTANGLE') {
            toggleModeBtn.innerHTML = 'POLYGON';
            anno.setDrawingTool('polygon');
          } else  {
            toggleModeBtn.innerHTML = 'RECTANGLE';
            anno.setDrawingTool('rect');
          }
        });
      },
      resize: function(width, height) {
      }

    };
  }
});
