# Reference jQuery
$ = jQuery

$.awesomeCropper = (inputAttachTo, options) ->
  # Default settings
  settings =
    width: 100
    height: 100
    debug: true

  # Merge default settings with options.
  settings = $.extend settings, options

  # Simple logger.
  log = (msg) ->
    console?.log msg if settings.debug

  # Input
  $inputAttachTo = $(inputAttachTo)

  input = (type) ->
    return $("<input type = \"#{type}\" />")

  div = () ->
    return $("<div/>")

  a = (text) ->
    return $("<a href=\"#\">#{text}</a>")

  image = () ->
    return $('<img/>')

  generateImputName = (f) ->
    name = $inputAttachTo.attr('name')
    if name.match /\]$/
      name.replace /\]$/, "_#{f}]"
    else
      name + "_#{f}"


  # Main box
  $container = div().insertAfter($inputAttachTo).addClass('awesome-cropper')

  # Inputs with URL, width, height, x, y
  $input_url = input('hidden').attr('name', generateImputName('url'))
  $input_x   = input('hidden').attr('name', generateImputName('x'))
  $input_y   = input('hidden').attr('name', generateImputName('y'))
  $input_w   = input('hidden').attr('name', generateImputName('w'))
  $input_h   = input('hidden').attr('name', generateImputName('h'))
  $container.append($input_url).append($input_x).append($input_y).append($input_w).append($input_h)

  # File chooser
  $fileSelect = input('file')
  $container.append(
    div().addClass('control-group')
      .append($fileSelect)
  )

  # URL input
  $urlSelect = input('text')
  $urlSelectButton = input('button')
  $urlSelectButton.val('Upload from url')

  $container.append(
    div().addClass('control-group form-inline')
      .append($urlSelect)
      .append($urlSelectButton)
  )

  # Drop area
  $dropArea = div().html('or Drop file here')
  $dropArea.addClass('awesome-cropper-drop-area well')
  $container.append(
    $dropArea
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

  # Modal dialog with cropping
  $sourceIm = image()
  $applyButton = a('Apply').addClass('btn btn-primary')
  $cancelButton = a('Cancel').addClass('btn').attr
    'data-dismiss': "modal"
    'aria-hidden': "true"

  $imagesContainer = div().append(
    div().addClass('modal-body row-fluid').append(
      div().addClass('span9')
        .append($sourceIm)
    ).append(
      div().addClass('span3 preview').css
        width: settings.width + "px"
        height: settings.height + "px"
        overflow: 'hidden'
      .append($previewIm)
    )
  ).append(
    div().addClass('modal-footer').append($cancelButton).append($applyButton)
  ).addClass('modal hide fade').attr
    role: 'dialog'
  $container.append($imagesContainer)

  # Plugin UI functions
  setLoading = () ->
    $progressBar.removeClass('hide')
 
  removeLoading = () ->
    $imagesContainer.modal()
    $progressBar.addClass('hide')

  setImages = (uri) ->
    $previewIm.attr('src', uri)
    $sourceIm.attr('src', uri)
    setAreaSelect($sourceIm)

  cleanImages = () ->
    $previewIm.attr('src', '')
    $sourceIm.attr('src', '')

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
        $input_x.val(selection.x1);
        $input_y.val(selection.y1);
        $input_w.val(selection.width);
        $input_h.val(selection.height);

  removeAreaSelect = (image) ->
    image.imgAreaSelect
      remove: true

  fixSize = (img) ->
    tempImage = new Image()
    width = 0

    tempImage.onload = () ->  
      width = tempImage.width
      r = width / img.width()
      $input_x.val($input_x.val() * r);
      $input_y.val($input_y.val() * r);
      $input_w.val($input_w.val() * r);
      $input_h.val($input_h.val() * r);

    tempImage.src = img.attr('src')

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

  saveCrop = () ->
    $input_url.val($sourceIm.attr('src'))
    fixSize($sourceIm)
    cleanImages()

  # Setup the listeners
  $fileSelect.bind('change', handleFileSelect)
  $dropArea.bind('dragover', handleDragOver)
  $dropArea.bind('drop', handleDropFileSelect)
  $urlSelectButton.click ->
    setLoading()
    setImages($urlSelect.val()).load () ->
      removeLoading()
  $cancelButton.click ->
    removeAreaSelect($sourceIm)
  $applyButton.click ->
    saveCrop()
    $imagesContainer.modal('hide')
    removeAreaSelect($sourceIm)


###
# jQuery Awesome Cropper plugin
#
# Copyright 2013 8xx8, vdv73rus
#
# v0.0.2
####
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
