export const toggleLoaderIOS = function(flag){
  console.log("inside toggle loader")
  return JBridge.toggleLoader(flag);
}

export const loaderTextIOS = function(mainTxt, subTxt){
  console.log("inside loader Text IOS")
  return JBridge.loaderText(mainTxt,subTxt);
}

export const getFromWindow = function (key) {
  if (typeof window[key] !== "undefined") {
    return window[key];
  }
}