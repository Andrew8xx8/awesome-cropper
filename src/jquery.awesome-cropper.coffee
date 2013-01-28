# Reference jQuery
$ = jQuery

$.awesomeCropper = (inputAttachTo, options) ->
  # Default settings
  settings =
    width: 100
    height: 100
    debug: true

  input = (type, name) ->
    return $("<input type = \"#{type}\" />")

  div = () ->
    return $("<div/>")

  image = () ->
    return $('<img/>')

  row = () ->
    div().addClass('row')


  # Merge default settings with options.
  settings = $.extend settings, options

  # Simple logger.
  log = (msg) ->
    console?.log msg if settings.debug

  # Input
  $inputAttachTo = $(inputAttachTo)

  # Main box
  $container = div().insertAfter($inputAttachTo).addClass('awesome-cropper row')

  # File chooser
  $fileSelect = input('file')
  $container.append(
    row().append(
      div().addClass('span6 control-group')
        .append($fileSelect)
    )
  )

  # URL input
  $urlSelect = input('text')
  $urlSelect.addClass('asd')
  $urlSelectButton = input('button')
  $urlSelectButton.val('Upload from url')

  $container.append(
    row().append(
      div().addClass('span4 control-group')
        .append($urlSelect)
    ).append(
      div().addClass('span2 control-group')
        .append($urlSelectButton)
    )
  )

  # Drop area
  $dropArea = div().html('or Drop file here')
  $dropArea.addClass('awesome-cropper-drop-area well')
  $container.append(
    row().append(
      div().addClass('span6 control-group')
      .append($dropArea)
    )
  )

  # Progress bar
  $progressBar = div().addClass('progress progress-striped active hide').append(
    div().addClass('bar').css('width', '100%')
  )
  $container.append($progressBar)

  # Image and preview
  $previewIm = image().css
    width: settings.width + "px"
    height: settings.height + "px"
    'max-width': 'none'

  $sourceIm = image()
  $imagesContainer = row().append(
    div().addClass('span9')
      .append($sourceIm)
  ).append(
    div().addClass('span3 preview').css
      width: settings.width + "px"
      height: settings.height + "px"
      overflow: 'hidden'
    .append($previewIm)
  )
  $container.append($imagesContainer)

  # Plugin UI functions
  setLoading = () ->
    $imagesContainer.hide()
    $progressBar.removeClass('hide')
 
  removeLoading = () ->
    $imagesContainer.show()
    $progressBar.addClass('hide')

  setImages = (uri) ->
    $previewIm.attr('src', uri)
    $sourceIm.attr('src', uri)
    setAreaSelect($sourceIm)

  setAreaSelect = (image) ->
    image.imgAreaSelect
      aspectRatio: '1:1' 
      handles: true 
      onSelectChange: (img, selection) =>
        scaleX = 100 / (selection.width || 1);
        scaleY = 100 / (selection.height || 1);

        $previewIm.css
          width: Math.round(scaleX * $(img).width()) + 'px',
          height: Math.round(scaleY * $(img).height()) + 'px',
          marginLeft: '-' + Math.round(100/selection.width * selection.x1) + 'px'
          marginTop: '-' + Math.round(100/selection.height * selection.y1) + 'px'
      onSelectEnd: (img, selection) =>
        input_format = $(img).attr('data-input-format')
        console.log($("input[id^=\"#{input_format}x\"]"))
        $("input[id*=\"#{input_format}x\"]").val(selection.x1);
        $("input[id*=\"#{input_format}y\"]").val(selection.y1);
        $("input[id*=\"#{input_format}w\"]").val(selection.width);
        $("input[id*=\"#{input_format}h\"]").val(selection.height);

  removeAreaSelect = (image) ->
    image.imgAreaSelect.remove()

  # Plugin images loading function
  readFile = (file) ->
    reader = new FileReader()

    setLoading()

    reader.onload = (e) ->
      setImages(e.target.result)
      removeLoading() 

    reader.readAsDataURL(file)

  handleDropFileSelect = (evt) ->
    evt.stopPropagation()
    evt.preventDefault()

    readFile(evt.originalEvent.dataTransfer.files[0])

  handleDragOver = (e) ->
    e.originalEvent.dataTransfer.dropEffect = "copy"
    e.stopPropagation()
    e.preventDefault()

  handleFileSelect = (evt) ->
    readFile(evt.target.files[0])

  # Setup the dnd listeners.
  $fileSelect.bind('change', handleFileSelect)
  $dropArea.bind('dragover', handleDragOver)
  $dropArea.bind('drop', handleDropFileSelect)
  $urlSelectButton.click ->
    setLoading()
    setImages($urlSelect.val()).load () ->
      removeLoading()


# Adds plugin object to jQuery
$.fn.extend
  awesomeCropper: (options) ->
    return @each ()->
      # Is there already an imgAreaSelect instance bound to this element? 
      if $(this).data("awesomeCropper")

        # Yes there is -- is it supposed to be removed? 
        if options.remove

          # Remove the plugin 
          $(this).data("awesomeCropper").remove()
          $(this).removeData "awesomeCropper"

          # Reset options 
        else
          $(this).data("awesomeCropper").setOptions options
      else unless options.remove
        # No exising instance -- create a new one 
        #
        $(this).data "awesomeCropper", new $.awesomeCropper(this, options)
      return $(this).data("awesomeCropper")  if options.instance
      this
