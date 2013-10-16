# Reference jQuery
$ = jQuery

$.awesomeCropper = (inputAttachTo, options) ->
  # Default settings
  settings =
    width: 100
    height: 100
    debug: false

  # Merge default settings with options.
  settings = $.extend settings, options

  # Simple logger.
  log = () ->
    console?.log arguments if settings.debug

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

  # Main box
  $container = div().insertAfter($inputAttachTo).addClass('awesome-cropper')

  $cropSandbox = $('<canvas></canvas>')
  $cropSandbox.attr
    width: settings.width
    height: settings.height

  $container.append($cropSandbox)

  # File chooser
  $fileSelect = input('file')
  $container.append($fileSelect)

  if (settings.proxy_path != undefined)
    # URL input
    $urlSelect = input('text')
    $urlSelectButton = input('button')
    $urlSelectButton.val('Upload from url')

    $container.append(
      div().addClass('form-group')
        .append($urlSelect)
        .append($urlSelectButton)
    )

  # Progress bar
  $progressBar = div().addClass('progress hide').append(
    div().addClass('progress-bar').attr(
      role: 'progressbar'
      'aria-valuenow': "60"
      'aria-valuemin': "0"
      'aria-valuemax': "100"
      style: "width: 60%;"
    )
  )
  $container.append($progressBar)

  # Result Image
  $resultIm = image()
  $container.append($resultIm)

  # Modal dialog with cropping
  $sourceIm = image()
  $applyButton = a('Apply').addClass('btn yes btn-primary')
  $cancelButton = a('Cancel').addClass('btn btn-danger').attr
    'data-dismiss': "modal"

  $imagesContainer = div().append(
    div().addClass('modal-dialog').append(
      div().addClass('modal-content').append(
        div().addClass('modal-body').append(
          div().addClass('col-md-9')
            .append($sourceIm)
        ).append(
          div().addClass('col-md-3')
          .append($cropSandbox)
        ).append(
          div().addClass('clearfix')
        )
        div().addClass('modal-footer').append(
          div().addClass('btn-group').append($cancelButton).append($applyButton)
        )
      )
    )
  ).addClass('modal').attr
    role: 'dialog'
  $container.append($imagesContainer)

  # Plugin UI functions
  removeAreaSelect = (image) ->
    image.imgAreaSelect
      remove: true

  cleanImages = () ->
    removeAreaSelect($sourceIm)
    im = $sourceIm
    $sourceIm = image()
    im.replaceWith($sourceIm)

  setLoading = () ->
    $progressBar.removeClass('hide')

  removeLoading = () ->

    $imagesContainer.on('shown.bs.modal', () ->
      setAreaSelect($sourceIm)
    ).on('hidden.bs.modal', () ->
      cleanImages()
    ).modal()

    $progressBar.addClass('hide')

  setOriginalSize = (img) ->
    tempImage = new Image()

    tempImage.onload = () ->
      img.attr
        'data-original-width': tempImage.width
        'data-original-height': tempImage.height

    tempImage.src = img.attr('src')

  setImages = (uri) ->
    $sourceIm.attr('src', uri).load ->
      removeLoading()
      setOriginalSize($sourceIm)

  drawImage = (img, x, y, width, height) ->
    oWidth = img.attr('data-original-width')
    oHeight = img.attr('data-original-height')

    if oWidth > oHeight
      r = oHeight / img.height()
    else
      r = oWidth / img.width()

    sourceX = Math.round(x * r)
    sourceY = Math.round(y * r)
    sourceWidth = Math.round(width  * r)
    sourceHeight = Math.round(height * r)
    destX = 0
    destY = 0
    destWidth = settings.width
    destHeight = settings.height

    context = $cropSandbox.get(0).getContext('2d')
    context.drawImage(img.get(0), sourceX, sourceY, sourceWidth, sourceHeight, destX, destY, destWidth, destHeight)

  setAreaSelect = (image) ->
    viewPort = $(window).height() - 150

    if $sourceIm.height() > viewPort
      $sourceIm.css
        height: viewPort + "px"

    log(image.width(), image.height())

    if (image.width() / settings.width >= image.height() / settings.height)
      y2 = image.height()
      x2 = Math.round(settings.width * (image.height() / settings.height))
    else
      x2 = image.width()
      y2 = Math.round(settings.height * (image.width() / settings.width))

    log(x2, y2, image.width(), image.height())

    drawImage($sourceIm, 0, 0, x2 - 1, y2 - 1)

    image.imgAreaSelect
      aspectRatio: "#{settings.width}:#{settings.height}"
      handles: true
      x1: 0
      y1: 0
      x2: x2
      y2: y2
      onSelectEnd: (img, selection) =>
        drawImage($sourceIm, selection.x1, selection.y1, selection.width - 1, selection.height - 1)

  # Plugin images loading function
  fileAllowed = (name) ->
    res = name.match /\.(jpg|png|gif|jpeg)$/mi
    if !res
      alert('Only *.jpeg, *.jpg, *.png, *.gif files allowed')
      false
    else
      true

  readFile = (file) ->
    reader = new FileReader()

    setLoading()

    reader.onload = (e) ->
      setImages(e.target.result)

    reader.readAsDataURL(file)

  handleDropFileSelect = (evt) ->
    evt.stopPropagation()
    evt.preventDefault()

    if evt.originalEvent.dataTransfer.files[0] != undefined
      return unless fileAllowed(evt.originalEvent.dataTransfer.files[0].name)

      readFile(evt.originalEvent.dataTransfer.files[0])

  handleDragOver = (e) ->
    e.originalEvent.dataTransfer.dropEffect = "copy"
    e.stopPropagation()
    e.preventDefault()

  handleFileSelect = (evt) ->
    if evt.target.files[0] != undefined
      return unless fileAllowed(evt.target.files[0].name)

      readFile(evt.target.files[0])
      evt.target.value = ""

  saveCrop = () ->
    result = $cropSandbox.get(0).toDataURL()
    $resultIm.attr('src', result)
    $inputAttachTo.val(result)
    cleanImages()

  # Setup the listeners
  $fileSelect.on('change', handleFileSelect)
  $container.on('dragover', handleDragOver)
  $container.on('drop', handleDropFileSelect)

  if (settings.proxy_path != undefined)
    $urlSelect.on('dragover', handleDragOver)
    $urlSelect.on('drop', handleDropFileSelect)

    $urlSelectButton.click ->
      return unless $urlSelect.val().match(/^(https?:\/\/)?/)
      return unless fileAllowed($urlSelect.val())

      setLoading()
      url = settings.proxy_path.replace /:url/, $urlSelect.val()
      $.get(url).done (data) ->
        setImages(data)
      .fail (jqXNR, textStatus) ->
        $progressBar.addClass('hide')
        alert("Failed to load image")

  $cancelButton.on 'click', ->
    cleanImages()

  $applyButton.on 'click', ->
    saveCrop()
    $imagesContainer.modal('hide')


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
