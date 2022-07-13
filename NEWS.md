### CHANGES IN recogito VERSION 0.2.0

- read_annotorious now extracts from x$target$selector instead of x$target[[1]]$value
- Allow to annotate using zoomable images using openseadragon
    - annotorious gains a type argument, allowing to use openseadragon for zoomable image selections
    - added openseadragonOutput, renderOpenSeaDragon, openseadragonOutputNoToolbar, renderOpenSeaDragonNoToolbar and backend functions for these
    - added javascript libraries (and updated LICENSE.note)
        - openseadragon-2.4.2
        - annotorious-2.5.10
        - annotorious-openseadragon-2.6.0
        - annotorious-shape-labels-0.2.4
        - annotorious-toolbar-1.1.1
        - annotorious-better-polygon-0.2.0

### CHANGES IN recogito VERSION 0.1.2

- Updated recogito-js library to version 1.7.1
- Added additional example shiny app for recogito relations

### CHANGES IN recogito VERSION 0.1.1

- Extra documentation

### CHANGES IN recogito VERSION 0.1

- Initial version of the package including recogito and annotorious
- Allow to build shiny apps to annotate text and images
