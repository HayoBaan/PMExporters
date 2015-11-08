/*

  No right clicking on images

  Requires:
    jquery.js

  Define elsewhere:
    noRightClickMsg <- Message to show when image is right clicked

  Developed by Hayo Baan (info@hayobaan.com)

*/

// To prevent right clicking on an item, set this as its mousedown function
function noRightClick(e) {
    if (!e) {
        e = window.event;
    }
    if (e.button == 2) {
        if (rightClickMsg != "") {
            alert(rightClickMsg);
        }
        return false;
    } else {
        return true;
    }
}

// To disable an item's context menu, set this as its context menu function
function noContextMenu(e) {
    return false;
}
