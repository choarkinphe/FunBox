function getImages(){
    var objs = document.getElementsByTagName("img");
    var imgScr = '';
    for(var i=0;i<objs.length;i++){
        imgScr = imgScr + objs[i].src + '+';
    };
    return imgScr;
};
function registerImageClickAction(){
    var imgs=document.getElementsByTagName('img');
    var length=imgs.length;
    for(var i=0;i<length;i++){
        img=imgs[i];
        img.onclick=function(){
            window.location.href='image-preview:'+this.src}
    }
}
document.documentElement.style.webkitTouchCallout='none';
