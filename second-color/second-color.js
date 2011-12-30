
// http://coding.pressbin.com/123/Second-Color-maps-seconds-to-RGBA-colors

var uniqueRGBA = function(yyyy, mo, dd, hh, mm, ss) {
   var begindate = new Date(Date.UTC('1941','09','09','00','00','00'));
   var begintime = begindate.getTime()/1000;

   var mydate = new Date(Date.UTC(yyyy, mo, dd, hh, mm, ss));
   var mytime = mydate.getTime()/1000;

   if (mytime < begintime || mytime - 4294967296 > begintime) {
      // specified date is outside our time boundary
      return false;
   }

   var elapsed = mytime - begintime;

   console.log(begintime);
   console.log(mytime);
   console.log(elapsed);

   var r = Math.floor(elapsed / (256*256*256));
   var rRemain = elapsed - (r*256*256*256);
   var g = Math.floor(rRemain / (256*256));
   var gRemain = rRemain - (g*256*256);
   var b = Math.floor(gRemain / 256);
   var bRemain = gRemain - (b*256);
   var a = Math.floor(bRemain);

   return { r : r, g : g, b : b, a : a };

};

console.log(uniqueRGBA(2011, 12, 29, 0, 0, 0))
