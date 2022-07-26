HTMLWidgets.widget({
  name: 'annotorious',
  type: 'output',
  factory: function(el, width, height) {
    anno = Annotorious.init({
      image: el.id,
      locale: 'auto',
      allowEmpty: true,
      formatter: Annotorious.ShapeLabelsFormatter()
    });
    Annotorious.Toolbar(anno, document.getElementById(el.id.concat("-outer-container")));
    // Default to rectangle annotation
    anno.setDrawingTool('rect');
    return {
      renderValue: function(x) {
        anno.on('createAnnotation', function(a) {
          Shiny.setInputValue(x.inputId, JSON.stringify(anno.getAnnotations()));
        });
        anno.on('updateAnnotation', function(a) {
          Shiny.setInputValue(x.inputId, JSON.stringify(anno.getAnnotations()));
        });
        anno.on('deleteAnnotation', function(a) {
          Shiny.setInputValue(x.inputId, JSON.stringify(anno.getAnnotations()));
        });
        Shiny.setInputValue(x.inputId, JSON.stringify([]));
        document.getElementById(el.id.concat("-img")).src = x.src;
        var tagset = x.tags;
        anno.clearAnnotations();
        //Shiny.setInputValue(x.inputId, JSON.stringify(anno.getAnnotations()));
        // Hack to clear the annotations areas shown as they seem not removed by using clearAnnotations
        //console.log(Array.from(document.querySelectorAll('.a9s-annotation')));
        const shapes = Array.from(document.querySelectorAll('.a9s-annotation'));
        Array.prototype.forEach.call( shapes, function( node ) {
          node.parentNode.removeChild( node );
        });
        // Quick selector widget showing buttons on top of the annotation widget
        var tagSelectorWidget = function(args) {
          // Triggers callbacks on user action
          var addTag = function(evt) {
            args.onAppendBody({
              type: 'TextualBody',
              purpose: 'tagging',
              value: evt.target.dataset.tag
            });
          };
          // Render the top buttons on top of the widget, using default shiny btn btn-default classes
          var createButton = function(value) {
            var button = document.createElement('button');
            button.className = "btn btn-default";
            button.dataset.tag = value;
            button.textContent = value;
            button.addEventListener('click', addTag);
            return button;
          };
          var container = document.createElement('div');
          container.className = 'tagset-quickselector-widget';
          tagset = x.tags;
          for (let i = 0; i < tagset.length; i++) {
            container.appendChild(createButton(tagset[i]));
          }
          return container;
        };
        if (x.tags === null){
          anno.widgets = [
            { widget: 'COMMENT' },
            { widget: 'TAG' }
          ];
        }else{
          anno.widgets = [
            { widget: 'COMMENT' },
            { widget: 'TAG', vocabulary: tagset },
            tagSelectorWidget
          ];
        }
        anno.refresh();
      },
      resize: function(width, height) {
      }
    };
  }
});
