/*

  Make the mainbody fill the rest of the page

  Requires:
    jQuery

  Developed by Hayo Baan (info@hayobaan.com)

*/

// Height of the mainbody
var mainbodyHeight=500;
var mainbodyWidth=800;

function verticalPos(elem) {
    return elem.offsetParent ? (elem.offsetTop + verticalPos(elem.offsetParent)) : elem.offsetTop;
}

function resizeBody() {
    mainbodyWidth=document.getElementById("mainbody").offsetWidth;
    mainbodyHeight=Math.max(200,$(window).height()-verticalPos(document.getElementById("mainbody")));
    $("#mainbody").css("height", mainbodyHeight+"px");
}
