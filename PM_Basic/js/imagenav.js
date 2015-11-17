/*

  Functions for image navigation

  Requires:
    jquery.js
    navhover.js
    norightclick.js
    resizebody.js

  Define elsewhere:    
    nrImages      <- The number of images
    images        <- Array of the images
    titles        <- Image titles
    subtitles     <- Image subtitles
    xSizes        <- Image widths
    maxxSize      <- Maximum image width
    ySizes        <- Image heights
    maxySize      <- Maximum image height
    thumbxSizes   <- Thumb widths
    maxthumbxSize <- Maximum thumb width
    thumbySizes   <- Thumb heights
    maxthumbySize <- Maximum thumb height

    highDPIImages     <- Set to true when @2x high DPI versions of images are available
    highDPIThumbs     <- Set to true when @2x high DPI versions of thumbs are available

    disableRightClick <- Set to true to disable right click on images
    slideshowDelay    <- Delay (in miliseconds) for the slideshows

  Developed by Hayo Baan (info@hayobaan.com)

*/

// *****************************************************************************
// Init
// *****************************************************************************

// Image indexes
var curimage = 0; // Current image
var middleID = 0; // ID # of middle (i.e., visile) fullimage

// Size of icons
var iconsize = 21;

// Margin
var margin = 14;

// Spacing constants for thumbs
var marginTBmain = 14;
var cellpadding = 0;
var cellborder = 2;
var cellspacing = 0;
var tableborder = 0;
var minthumbsize = Math.max(maxthumbxSize, maxthumbySize) / 2;

// Spacing constants for full image
var fullimagespacing = 5;

// Full image shown?
var fullimageShown = false;

// Title of full image shown?
var titleShown = false;

// Running slideshow?
var slideshowRunning = false;

// In a move?
var movingImages = false;

// *****************************************************************************
// File handling
// *****************************************************************************

var imgObj = new Image(); // Dummy object used to load images

// Load an image, calling the callback after the image has been fully loaded
function loadImage(file, callback) {
    imgObj.src = file;
    if (!imgObj.complete) {
        // Wait 0.1 seconds beforing trying again
        setTimeout(function () { loadImage(file, callback) }, 100);
    } else {
        callback();
    }
}

function isHighDPI() {
    return (window.devicePixelRatio > 1);
}

function highDPIFileName(name, highDPIEnabled) {
    if (highDPIEnabled && isHighDPI()) {
        name = name.replace(".jpg", "@2x.jpg");
    }
    return name;
}

// Determine image file for given image index
function imageFilespec(imgindex) {
    return "images/" + highDPIFileName(images[imgindex], highDPIImages);
}

// Determine thumb file for given image index
function thumbFilespec(imgindex) {
    return "thumbs/" + highDPIFileName(images[imgindex], highDPIThumbs);
}

// Return the file as url(file) string
function urlFromFile(file) {
    return "url(" +  encodeURI(file).replace("(","%28").replace(")","%29") + ")";
}

// *****************************************************************************
// Body creation
// *****************************************************************************

// Recreate complete html of body upon resize
var targetxFull = maxxSize;
var targetyFull = maxySize;
function createBody() {
    // Total width and height available for thumb cells
    var totalWidth = Math.max(minthumbsize+cellspacing+2*(cellpadding+cellborder),mainbodyWidth - 2*margin - 2*tableborder - 2*cellspacing - 2*(iconsize+margin));
    var totalHeight = Math.max(minthumbsize,mainbodyHeight - 2*marginTBmain - 2*tableborder - cellspacing);

    // Target size for thumbs
    var targetThumb = Math.sqrt(totalWidth*totalHeight/nrImages);
    var nrColumns = Math.min(Math.ceil(totalWidth/targetThumb),Math.floor(totalWidth/minthumbsize));
    if (nrColumns == 0) {
        nrColumns = 1;
    }
    var nrRows = Math.ceil(nrImages/nrColumns);
    if (nrRows == 0) {
        nrRows = 1;
    }
    if (nrColumns == 1) {
        nrRows = nrImages;
    } else if (nrRows*nrColumns-nrImages > (nrRows-1) && nrColumns > 1 & nrRows > 1) {
        //nrColumns -= 1;
    }
    targetThumb = Math.max(minthumbsize,Math.floor(Math.min(2/3*Math.max(maxthumbxSize,maxthumbySize)-1,Math.min(totalWidth/nrColumns,totalHeight/nrRows)-cellspacing-2*(cellpadding+cellborder))));
    var paddingTop = Math.max(0,Math.floor((totalHeight - nrRows*(targetThumb+2*(cellpadding+cellborder)+cellspacing) + cellspacing)/2)) + marginTBmain;
    var paddingIconTB = Math.max(0,Math.floor((nrRows*(targetThumb+2*(cellpadding+cellborder)+cellspacing) - cellspacing - iconsize)/2));
    var paddingIconLR = Math.max(Math.floor((totalWidth - nrColumns*(targetThumb+2*(cellpadding+cellborder)+cellspacing)+cellspacing)/2));

    var htmlCode = "<div style=\"padding-top: " + paddingTop + "px;\"><table border=\"" + tableborder + "\" cellspacing=\"" + cellspacing + "\" cellpadding=\"" + cellpadding + "\"><tbody>\n";
    var i;
    for (i=0; i<nrImages; i++) {
        if ((i+1 % nrColumns) == 0) {
            htmlCode += "<tr>\n";
        }
        var bgSizeSpec = "cover";
        if (targetThumb > thumbxSizes[i] || targetThumb > thumbySizes[i]) {
            if (thumbxSizes[i] > thumbySizes[i]) {
                bgSizeSpec = thumbxSizes[i] + "px auto"
            } else {
                bgSizeSpec = "auto " + thumbySizes[i] + "px"
            }
        }
        htmlCode += "<td class=\"thumb\" style=\"background-image: " + urlFromFile(thumbFilespec(i)) + "; background-size: " + bgSizeSpec + ";\"><img src=\"icons/empty.png\" alt=\"" + titles[i] + "\" title=\"" + titles[i] + "\" id=\"thumb" + i + "\" class=\"thumb\" style=\"width: " + targetThumb + "px; height: " + targetThumb + "px;\" /></td>\n";
        if ((i+1) % nrColumns == 0) {
            htmlCode += "</tr>\n";
        }
    }
    if (nrImages % nrColumns != 0) {
        for (i = 0; i < (nrColumns - (nrImages % nrColumns)); i++) {
            htmlCode += "<td>&nbsp;</td>\n";
        }
        htmlCode += "</tr>\n";
    }
    htmlCode += "</tbody></table></div>";
    document.getElementById("mainbody").innerHTML = htmlCode;
    
    // On click of thumb, show full version
    $("img[id^=thumb]").click(showFullImage);
    // Add hovering and norightclick for thumbs
    $("img[id^=thumb]").hover(hoverThumbOn, hoverThumbOff);
    if (disableRightClick) {
        $("img[id^=thumb]").mousedown(noRightClick);
        $("img[id^=thumb]").contextmenu(noContextMenu);
    }

    $("#slideshow").css("padding-left", Math.max(0,($(window).width()-iconsize))/2);
    $("#slideshow").css("padding-right", Math.max(0,($(window).width()-iconsize))/2);
    
    // Target sizes for full image
    targetxFull = Math.min(maxxSize, $(window).width() - 2*(iconsize+fullimagespacing+margin));
    targetyFull = Math.min(maxySize, $(window).height() - 2*(iconsize+fullimagespacing+margin/2));
    $("#fullimagebg").css("width", $(window).width() + "px");
    $("#fullimagebg").css("height", $(window).height() + "px");
    $("#fullimagetitle_1").css("width", $(window).width()-2*margin + "px");
    $("#fullimagetitle_0").css("width", $(window).width()-2*margin + "px");
    $("#fullimagetitle_2").css("width", $(window).width()-2*margin + "px");
}

// *****************************************************************************
// Thumb hovering
// *****************************************************************************

// Thumb hover on
function hoverThumbOn() {
    // Hack IE hover bug
    if (navigator.userAgent.search(/\bMSIE [0-6]/) > -1) {
        $(this).addClass("thumbhover");
    }
    curimage = parseInt(this.id.replace("thumb", ""));       
    $("#image_title").html(titles[curimage]);
    $("#image_subtitle").html(subtitles[curimage]);
}

// Thumb hover off
function hoverThumbOff() {
    if (navigator.userAgent.search(/\bMSIE [0-6]/) > -1) {
        // Hack IE hover bug
        $(this).removeClass("thumbhover");
    }
    $("#image_title").html("&nbsp;");
    $("#image_subtitle").html("&nbsp;");
}

// Initialise hover for buttons on page
$(document).ready(function () {
    $("#imageleft").hover(hoverNavOn, hoverNavOff);
    $("#imageright").hover(hoverNavOn, hoverNavOff);
    $("#slideshow").hover(hoverNavOn, hoverNavOff);
});


// *****************************************************************************
// Key press handling
// *****************************************************************************

// Process key press
function processKeyPress(e) {
    if (!e) {
        e = window.event;
    }

    var key = e.keyCode;
    if (!key) {
        key = e.which;
    }

    var processed = false;
    switch (key) {
    case 32: // Space
        processed = true;
        toggleSlideshow();
        break;
    case 27: // Escape
    case 38: // Up
        processed = true;
        if (fullimageShown) {
            stopSlideshow();
            hideFullImage();
        }
        break;
    case 37: // Left
        processed = true;
        if (fullimageShown) {
            showPrevNextImg(-1);
        }
        break;
    case 39: // Right
        processed = true;
        if (fullimageShown) {
            showPrevNextImg(1);
        }
        break;
    default:
        break;
    }
    return !processed;
}


// Initialise key press processing
$(document).ready(function initKeyPress() {
    // Only Opera and Firefox seem to correctly (?) handle keyPress and keyDown events
    if (navigator.userAgent.search(/Firefox|Opera/) > -1) {
        document.onkeypress=processKeyPress;
    } else {
        document.onkeydown=processKeyPress;
    }
});


// *****************************************************************************
// Main image handling
// *****************************************************************************

// Determine exact size of full image
var imageFullX = maxxSize;
var imageFullY = maxySize;
function imageFullXY(idx) {
    var xFactor = targetxFull / xSizes[idx];
    var yFactor = targetyFull / ySizes[idx];
    var factor = Math.min(1, xFactor, yFactor);
    imageFullX = Math.floor(factor*xSizes[idx]);
    imageFullY = Math.floor(factor*ySizes[idx]);
}

// Left Middle Right full image ID (-1, 0, +1)
function leftMiddleRightID(d) {
    id = middleID+d;
    if (id<0) {
        id = 2;
    }
    if (id>2) {
        id = 0;
    }
    return id;
}

// Setup a single full image (idx relative to middle)
function setFullImage(d) {
    fullimageID = leftMiddleRightID(d);
    imageIDX = prevNextImg(d);
    imageFullXY(imageIDX);
    // Note: the left and right image are both positioned to the left to prevent
    // being able to "scroll" to the right image on mobile devices
    $("#fullimage_" + fullimageID).css("left", Math.floor(($(window).width()-imageFullX)/2 + (d == 0 ? 0 : -$(window).width())) + "px");
    $("#fullimage_" + fullimageID).css("bottom", Math.floor(($(window).height()-imageFullY)/2) + "px");
    $("#fullimage_" + fullimageID).css("width", imageFullX + "px");
    $("#fullimage_" + fullimageID).css("height", imageFullY + "px");
    $("#fullimage_" + fullimageID).attr("title", title[imageIDX]);
    $("#fullimage_" + fullimageID).attr("alt", title[imageIDX]);
    $("#fullimage_" + fullimageID).css("background-image", urlFromFile(imageFilespec(imageIDX)));
    $("#fullimagetitle_" + fullimageID).html("<h1>"+titles[imageIDX]+"</h1><h2>"+subtitles[imageIDX]+"</h2>");
    $("#fullimagetitle_" + fullimageID).css("left", (d == 0 ? 0 : -$(window).width()) + "px");
}

// Setup the full image attributes
function setFullImages() {
    // Setup the full images
    setFullImage(-1); // The image on the left
    setFullImage(1); // The image on the right
    setFullImage(0); // The currently visible image (set last to retain image sizes)

    // Setup the left and right image icons
    var paddingLR = Math.max(0,Math.floor(($(window).width()-imageFullX-2*(iconsize+margin))/2));
    var paddingTB = Math.max(0,Math.floor(($(window).height()-iconsize)/2));
    $("#imageleft").css("padding-right", paddingLR);
    $("#imageleft").css("padding-top", paddingTB);
    $("#imageleft").css("padding-bottom", paddingTB);
    $("#imageright").css("padding-left", paddingLR);
    $("#imageright").css("padding-top", paddingTB);
    $("#imageright").css("padding-bottom", paddingTB);
    document.getElementById("imageleft").title = titles[prevNextImg(-1)];
    document.getElementById("imageright").title = titles[prevNextImg(1)];
};

// Show the full image
function showFullImage() {
    if (!fullimageShown) {
        titleShown = false;
        if (this == window) {
            curimage = 0;
        } else {
            curimage = parseInt(this.id.replace("thumb", ""));
        }
        loadImage(imageFilespec(prevNextImg(0)), function () {
            setFullImages();
            fullimageShown = true;
            showTitle(undefined,600);
            $("#fullimagebg").fadeIn(600);
            $("#fullimage_1").fadeIn(600);
            $("#fullimage_0").fadeIn(600);
            $("#fullimage_2").fadeIn(600);
            $("#imageleft").fadeIn(600);
            $("#imageright").fadeIn(600);
        });
    }
}

// Hide the full image
function hideFullImage() {
    if (fullimageShown) {
        stopSlideshow();
        hideTitle(undefined,600);
        $("#fullimage_1").fadeOut(600);
        $("#fullimage_0").fadeOut(600);
        $("#fullimage_2").fadeOut(600);
        $("#fullimagebg").fadeOut(600);
        $("#imageleft").fadeOut(600);
        $("#imageright").fadeOut(600);
        fullimageShown = false;
    }
}

// Index of prev/image (loops)
function prevNextImg(d) {
    idx = curimage+d;
    if (idx < 0) {
        idx = nrImages-1;
    }
    if (idx >= nrImages) {
        idx = 0;
    }
    return idx;
}

// Holds the value of the last next/prev
var lastprev=0;

// Show prev/next image
function showPrevNextImg(d) {
    lastnextprev=d;

    // Return if already busy moving an image
    if (movingImages) {
        return;
    }

    if (slideshowRunning) {
        clearTimeout(slideshowTimerId); // Cancel any existing timeout
        slideshowTimerId = setTimeout(nextSlideshowImage, slideshowDelay);
    }
    
    // Move images
    movingImages = true;

    // Load the next image and move into place when fully loaded
    loadImage(imageFilespec(prevNextImg(lastnextprev)), function () {
        // First move the "right" image to its proper location
        imageFullXY(prevNextImg(1));
        $("#fullimage_" + leftMiddleRightID(1)).css("left", Math.floor(($(window).width()-imageFullX)/2 + $(window).width()) + "px");
        $("#fullimagetitle_" + leftMiddleRightID(1)).css("left", $(window).width() + "px");
    
        // Start animations
        $("#fullimagetitle_" + leftMiddleRightID(-1)).animate({ "left": "-=" + d*$(window).width() },400);
        $("#fullimage_" + leftMiddleRightID(-1)).animate({ "left": "-=" + d*$(window).width() },400);
        $("#fullimagetitle_" + leftMiddleRightID(1)).animate({ "left": "-=" + d*$(window).width() },400);
        $("#fullimage_" + leftMiddleRightID(1)).animate({ "left": "-=" + d*$(window).width() },400);
        $("#fullimagetitle_" + leftMiddleRightID(0)).animate({ "left": "-=" + d*$(window).width() },400);
        $("#fullimage_" + leftMiddleRightID(0)).animate({ "left": "-=" + d*$(window).width() },400, function() {
            // Set new current image
            curimage = prevNextImg(lastnextprev);
            middleID = leftMiddleRightID(lastnextprev);
            // Update images
            setFullImages();
            // Show title
            showTitle(undefined,150);
            movingImages = false;
        });
    });
}

// *****************************************************************************
// Functions for handling title of full image
// *****************************************************************************

var titleTimerId = 0;

// Show title
function showTitle(event, fadetime) {
    if (fadetime == undefined) {
        fadetime = 150;
    }
    clearTimeout(titleTimerId); // Cancel any existing timeout
    if (fullimageShown) {
        $("#fullimagetitle_" + leftMiddleRightID(-1)).fadeIn(fadetime, function () {
            $("#fullimagetitle_" + leftMiddleRightID(-1)).css("opacity", 0.70); // Callback for IE
        });
        $("#fullimagetitle_" + leftMiddleRightID(1)).fadeIn(fadetime, function () {
            $("#fullimagetitle_" + leftMiddleRightID(1)).css("opacity", 0.70); // Callback for IE
        });
        $("#fullimagetitle_" + leftMiddleRightID(0)).fadeIn(fadetime, function () {
            $("#fullimagetitle_" + leftMiddleRightID(0)).css("opacity", 0.70); // Callback for IE
            clearTimeout(titleTimerId); // Make sure no other timeout was set in between
            titleTimerId = setTimeout(hideTitle, 2000);
            titleShown = true;
        });
    }
}


// Hide title
function hideTitle(event, fadetime) {
    if (fadetime == undefined) {
        fadetime = 150;
    }
    clearTimeout(titleTimerId); // Cancel any other existing timeout
    if (titleShown) {
        titleShown = false;
        $("#fullimagetitle_" + leftMiddleRightID(-1)).fadeOut(fadetime);
        $("#fullimagetitle_" + leftMiddleRightID(0)).fadeOut(fadetime);
        $("#fullimagetitle_" + leftMiddleRightID(1)).fadeOut(fadetime);
    }
}


// *****************************************************************************
// Slideshow functions
// *****************************************************************************

var slideshowTimerId = 0;

function startSlideshow(event) {
    if (!slideshowRunning) {
        clearTimeout(slideshowTimerId); // Cancel any existing timeout
        slideshowRunning = true;
        $("#slideshow").attr("src", "icons/pause.png");
        if (!fullimageShown) {
            showFullImage();
            slideshowTimerId = setTimeout(nextSlideshowImage, 5000);
        } else {
            nextSlideshowImage();
        }
        showNavElement("slideshow",true);
    }
}

function stopSlideshow(event) {
    clearTimeout(slideshowTimerId); // Cancel any existing timeout
    slideshowRunning = false;
    $("#slideshow").attr("src", "icons/play.png");
    showNavElement("slideshow",true);
}

function nextSlideshowImage(event) {
    showPrevNextImg(1);
}


function toggleSlideshow(event) {
    if (slideshowRunning) {
        stopSlideshow();
    } else {
        startSlideshow();
    }
}


// *****************************************************************************
// Initialisation
// *****************************************************************************

// Update sizes and display on resize
$(window).resize(function () {
    resizeBody();

    createBody();
    if (fullimageShown) {
        setFullImages();
    }
});

// Init
$(document).ready(function () {
    resizeBody();

    for (var i=0; i<3; i++) {
        // Start showing title upon entering image
        $("#fullimage_" + i).mouseenter(showTitle);
        if (disableRightClick) {
            // Add no right click/no context menu handler to full images
            $("#fullimage_" + i).mousedown(noRightClick);
            $("#fullimage_" + i).contextmenu(noContextMenu);
        }
    }

    // Create the body
    createBody();
});
