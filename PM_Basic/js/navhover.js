/*

  Functions for adding hover effects to navigation elements

  Requires:
    jquery.js

  Developed by Hayo Baan (info@hayobaan.com)

*/


// Show correct version of a navigation element
function showNavElement(id, active) {
    var suf = "";
    if (!active) {
        suf = "_";
    } else {
        if (document.getElementById(id).className.search(/\bhover\b/) > -1) {
            suf = "__";
        }
    }
    document.getElementById(id).src = document.getElementById(id).src.replace(/_*.png/, suf + ".png");;
}


// Show highlighted version of a navigation element
function hoverNavOn() {
    $(this).addClass("hover");
    if (this.src.search(/_.png/) < 0) {
        this.src = this.src.replace(".png","__.png");
    }
}


// Show normal version of a navigation element
function hoverNavOff() {
    $(this).removeClass("hover");
    if (this.src.search(/__.png/) > -1) {
        this.src = this.src.replace("__.png",".png");
    }
}

