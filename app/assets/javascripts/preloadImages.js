var preloadedImages = []
function preloadImages() {
    for (var idx = 0; idx < arguments.length; idx++) {
        var oneImage = new Image()
        oneImage.src = arguments[idx]
        preloadedImages.push(oneImage)
    }
}