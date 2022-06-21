HTMLWidgets.widget({
  name: 'recogito',
  type: 'output',
  factory: function(el, width, height) {
    var formatter = function(annotation) {
      return "tag-".concat(annotation.body[0].value)
    }
    var r = Recogito.init({content: el.parentNode.id});
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
        function updateAnnotation(){
           Shiny.setInputValue(r._environment.inputId, JSON.stringify(r.getAnnotations()));
        }
        function createAnnotation(){
           Shiny.setInputValue(r._environment.inputId, JSON.stringify(r.getAnnotations()));
        }
    return {
      renderValue: function(x) {
        el.innerText = x.text;
        r._environment.inputId=x.inputId;
        r.off('updateAnnotation',updateAnnotation);
        r.on('updateAnnotation', updateAnnotation);
        r.off('createAnnotation',createAnnotation);
        r.on('createAnnotation',createAnnotation);
        if(x.refresh){
          r.clearAnnotations();
          //TODO: verify annotations exist and are correctly formatted
          //The tags can be misaligned when text contains multiple 
          //spaces or special characters. 
          alert(x.annotations);
          if(x.annotations!="{}" & x.annotations!='[""]'){
            r.setAnnotations(JSON.parse(x.annotations)) 
          }
        }
        //var toggleModeBtn = document.getElementById('toggle-mode');
        //r.refresh();
      },
      resize: function(width, height) {
      }
    };
  s: r
  }
});
