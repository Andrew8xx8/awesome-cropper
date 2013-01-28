# Awesome Cropper

Awesome croper is jQuery plugin to produce form component that can
upload images from local and remote destinations and set crop area.

WorkFlow:

- Select Image by File Select, Url or Drag'n'Drop
- Crop Image to specific size in modal window
- Upload image with selected area coords

## Dependencies

- [Twitter Bootstrap](http://twitter.github.com/bootstrap)
- [jQuery](http://jquery.com/)
- [imgAreaSelect](http://www.odyniec.net/projects/imgareaselect/)

## Usage

Load script and styles of plugin:

```html
  <script src="build/jquery.awesome-cropper.js"></script>

  <link rel="stylesheet" href="css/jquery.awesome-cropper.css">
```

Create cropping component on some hidden input:
```html
  <script>
  $(document).ready(function () {
      $('#sample_input').awesomeCropper(
        { maxWidth: 200, maxHeight: 150, handles: true }
      );
  });
  </script>
```

Hidden input may looks like this:
```html
  <input id="sample_input" type="hidden" name="test[image]">
```

