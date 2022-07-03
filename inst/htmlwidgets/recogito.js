HTMLWidgets.widget({
  name: 'recogito',
  type: 'output',
  factory: function(el, width, height) {
    var formatter = function(annotation) {
      return "tag-".concat(annotation.body[0].value)
    }
    var data = document.getElementById(el.id.concat("-data"));
    var initData = JSON.parse(data.getAttribute("init-data"));
    var r = Recogito.init({
                            content: el.parentNode.id,
                            mode: initData.mode,
                            formatter: formatter,
                            widgets:['COMMENT',
                                    { widget: 'TAG', vocabulary: initData.tags}
                                    ],
                            relationVocabulary: initData.rtags,
                            readOnly: false                         
                          });
        function updateAnnotation(){
           Shiny.setInputValue(r._environment.inputId, JSON.stringify(r.getAnnotations()));
        }
        function createAnnotation(){
           Shiny.setInputValue(r._environment.inputId, JSON.stringify(r.getAnnotations()));
        }
    return {
      renderValue: function(x) {
        r._environment.inputId=x.inputId;
        if(x.refresh){
          el.innerText = x.text;
          r.off('updateAnnotation',updateAnnotation);
          r.on('updateAnnotation', updateAnnotation);
          r.off('createAnnotation',createAnnotation);
          r.on('createAnnotation',createAnnotation);
          r.clearAnnotations();
          //TODO: verify annotations exist and are correctly formatted
          //The tags can be misaligned when text contains multiple 
          //spaces or special characters.
          if(x.annotations!="{}" & x.annotations!='[""]'){
            r.setAnnotations(JSON.parse(x.annotations));
            Shiny.setInputValue(r._environment.inputId, JSON.stringify(r.getAnnotations()));
          }
        }
          if(x.annotations!="{}" & x.annotations!='[""]'){
            r.setAnnotations(JSON.parse(x.annotations));
            Shiny.setInputValue(r._environment.inputId, JSON.stringify(r.getAnnotations()));
          }
        if(x.annotationMode === 'RELATIONS'){
            r.setMode(x.annotationMode)
        }else{
          if(x.annotationMode === 'ANNOTATION'){
            r.setMode(x.annotationMode)
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
