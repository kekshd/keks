var isMobileBrowser = (/android|webos|iphone|ipad|ipod|blackberry|iemobile|opera mini/i.test(navigator.userAgent.toLowerCase()));

$.fx.off = isMobileBrowser;
window.animationDisabled = isMobileBrowser;
