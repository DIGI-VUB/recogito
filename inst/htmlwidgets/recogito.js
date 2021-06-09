HTMLWidgets.widget({
  name: 'recogito',
  type: 'output',
  factory: function(el, width, height) {
    var formatter = function(annotation) {
      return "tag-".concat(annotation.body[0].value)
    }
    return {
      renderValue: function(x) {
        el.innerText = x.text;
        var r = Recogito.init({
          content: el.parentNode.id,
          mode: x.mode,
          formatter: formatter,
          widgets: [
            'COMMENT',
            { widget: 'TAG', vocabulary: x.tags }
          ],
          readOnly: false
        });
        r.on('updateAnnotation', function(a) {
          Shiny.setInputValue(x.inputId, JSON.stringify(r.getAnnotations()));
        });
        r.on('createAnnotation', function(a) {
          Shiny.setInputValue(x.inputId, JSON.stringify(r.getAnnotations()));
        });
        //var toggleModeBtn = document.getElementById('toggle-mode');
        var toggleModeBtn = document.getElementById(el.id.concat("-toggle"));
        //var annotationMode = 'ANNOTATION';
        //r.setMode(annotationMode);
        annotationMode = toggleModeBtn.innerHTML;
        if (annotationMode === 'MODE: RELATIONS') {
          annotationMode = 'RELATIONS';
        } else  {
          annotationMode = 'ANNOTATION';
        }
        toggleModeBtn.addEventListener('click', function() {
          if (annotationMode === 'ANNOTATION') {
            toggleModeBtn.innerHTML = 'MODE: RELATIONS';
            annotationMode = 'RELATIONS';
          } else  {
            toggleModeBtn.innerHTML = 'MODE: ANNOTATION';
            annotationMode = 'ANNOTATION';
          }
          r.setMode(annotationMode);
        });
        //r.refresh();
      },
      resize: function(width, height) {
      }
    };
  }
});
