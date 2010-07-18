

function validate(){
 if( (validateNumber(document.form1.p_value.value)) && (validateNumber(document.form1.n_nodes.value)) )
  {
     if( (isEmpty(document.form1.upload_file.value))&&(isEmpty(document.form1.edit_functions.value)) )
     {
	    alert("Please upload a function file to continue.");
        return false;
     }
    return true;
   }
  else
  {
   return false;
  }
 }
function isEmpty(val) {
  return ( ( val == null ) || (val.length == 0) )
}
function validateNumber(num) {
 if(isEmpty(num))
   {
     alert("Cannot accept empty input.");
     return false;
   }
  for(i = 0; i < num.length; i++)
  {
     var c = num.charAt(i);
     if(!((c >= "0") && (c <= "9")))
      {
	alert("Input must be a positive integer.");
         return false;
      }
  }
   return true;
}
function validatePrime(prime) {
  if(!(validateNumber(prime)) )
   {
    return false;
   }
   if(prime == 1)
   {
    alert(prime + " is not a prime number.");
    return false;
   }
   for(i = 2; i <= Math.sqrt(prime); i++)
   {
      if( (prime%i) == 0 )
      {
	alert(prime + " is not a prime number.");
         return false;
      }
   }
 return true;
}

function doWarn(element) {
if(element.value == "Yes"){
  alert("WARNING!! May not be able to display graph with a large number of nodes");
  return true;
 }
 else {
  return false;
 }
}
/*function doFileWarn(element) {
if(element.value == "No"){
  alert("REMINDER!! Please make sure your polynomial function file adheres to the specified format.");
  return true;
 }
 else {
  return false;
 }
}*/

// This code is from Dynamic Web Coding www.dyn-web.com 
// Copyright 2002 by Sharon Paine Permission granted to use this code as long as this entire notice is included.
// Permission granted to SimplytheBest.net to feature script in its
// DHTML script collection at http://simplythebest.net/scripts/dhtml_scripts.html

var dom = (document.getElementById) ? true : false;
var ns5 = ((navigator.userAgent.indexOf("Gecko")>-1) && dom) ? true: false;
var ie5 = ((navigator.userAgent.indexOf("MSIE")>-1) && dom) ? true : false;
var ns4 = (document.layers && !dom) ? true : false;
var ie4 = (document.all && !dom) ? true : false;
var nodyn = (!ns5 && !ns4 && !ie4 && !ie5) ? true : false;

var origWidth, origHeight;
if (ns4) {
	origWidth = window.innerWidth; origHeight = window.innerHeight;
	window.onresize = function() { if (window.innerWidth != origWidth || window.innerHeight != origHeight) history.go(0); }
}

if (nodyn) { event = "nope" }
var tipFollowMouse	= true;	
var tipWidth		= 200;
var offX		 	= 12;	// how far from mouse to show tip
var offY		 	= 12; 
var tipFontFamily 	= "Verdana, arial, helvetica, sans-serif";
var tipFontSize		= "8pt";
var tipFontColor		= "#000000";
var tipBgColor		= "#DDECFF"; 
var origBgColor 		= tipBgColor; // in case no bgColor set in array
var tipBorderColor 	= "#000080";
var tipBorderWidth 	= 2;
var tipBorderStyle 	= "ridge";
var tipPadding	 	= 4;

var messages = new Array();
messages[0] = new Array('This is the number <b>\'n\'</b> of nodes in your discrete dynamical system.',"#DDECFF");
//messages[1] = new Array('This is the number <b>\'p\'</b> of different states each node can take on.<br><br>\'p\' must be <b>prime</b>.<br><br>If each node can take on 3 possible states, then \'p\'=3 and the states are represented by 0, 1, 2.',"#DDECFF");
messages[1] = new Array('This is the number <b>\'m\'</b> of different states each node can take on.',"#DDECFF"); messages[2] = new Array('The file must be a plain text file and adhere to the format specified in the tutorial, unless you select <b>GINsim File</b>, in which case it must be a GINsim file ending with the extension \'ginml\'. The number of functions in this file must equal the \'number of nodes\' value entered above.<br> For each variable a single update function or a set of update functions (in curly brackets) can be given.  In the latter, probabilites can be given, seperated formt he function by the pound sign',"#DDECFF");
//messages[3] = new Array('This will specify how the operations in the function file should be interpreted.<br><br>For example, \'x1*x2\' could be interpreted as polynomial multiplication of variables or as the Boolean AND operation.',"#DDECFF");
messages[3] = new Array('This will specify how the operations in the function file should be interpreted. <br><br><b>Polynomial</b>: the operations are interpreted as polynomial addition and multiplication<br><b>Boolean</b>: the operations are interpreted as Boolean AND, OR, and NOT. Note that the \'number of states\' value must be 2.',"#DDECFF");
//messages[4] = new Array('This will determine the order in which to evaluate
//the functions, whether synchronously (all functions get evaluated at the
//same time) or sequentially (the functions are evaluated in some
//order).<br><br>If \'Sequential\' is selected, an ordering of all function
//(or variable) indices must be entered, separated by spaces, with each index
//used exactly once.<br><br>For a 3-node network in which the functions are
//evaluated in the order f2 first, then f3, and f1 last, the ordering entered is \'2 3 1\'.',"#DDECFF");
messages[4] = new Array('This will determine the order in which to evaluate the functions.<br><br><b>Synchronous</b>: all functions get evaluated at the same time. The input can be a deterministic system, or a set of update functions for each variable<br><b>Update Stochastic</b>: this uses a random sequential update order. That is implemented by randomly delaying most variables and only updateing a few. The input has to be a deterministic system<br><b>Sequential</b>: the functions are evaluated in some specified order. The function indices must be entered with each index used exactly once.  Input must be deterministic',"#DDECFF"); 
messages[5] = new Array('Displays information about the structure of the trajectory graph generated using all possible states or a single user-provided initial state.',"#DDECFF");
messages[6] = new Array('<b>State space graph</b>: draws the graph of all trajectories or a single trajectory as requested by the user, probabilities on each edge can be included.<br><br><b>Dependency graph</b>: draws the dependency graph of the network described by the input functions.',"#DDECFF")
messages[7] = new Array('A rundown of the options: <br><br><b>Conjunctive/Disjunctive Networks</b>: For systems with only AND functions or only OR functions. All fixed points and limit cycles will be calculated.<br><b>Small Networks</b>: For n < 10. Enumerates all possible states. Outputs at minimum fixed points and number of components. See \'Small Networks Options\' for other output options.<br><b>Large Networks</b>: For n > 10. Calculates limit cycles of a length that the user specifies.<br>', "#DDECFF")
messages[8] = new Array('<b>GINsim File</b>: Converts GINsim file to a polynomial system that AVDD will then proceed to analyze. Also outputs the variables and the converted system.', "#DDECFF")
/*if (document.images) {
	var theImgs = new Array();
	for (var i=0; i<messages.length; i++) {
  	theImgs[i] = new Image();
		theImgs[i].src = messages[i][0];
  }
}*/

var startStr = '<table width="' + tipWidth + '"><tr><td align="left" width="100%">';
//var midStr = '</td></tr><tr><td valign="top">';
var endStr = '</td></tr></table>';

var tooltip, tipcss;
function initTip() {
	if (nodyn) return;
	tooltip = (ns4)? document.tipDiv.document: (ie4)? document.all['tipDiv']: (ie5||ns5)? document.getElementById('tipDiv'): null;
	tipcss = (ns4)? document.tipDiv: tooltip.style;
	if (ie4||ie5||ns5) {	// ns4 would lose all this on rewrites
		tipcss.width = tipWidth+"px";
		tipcss.fontFamily = tipFontFamily;
		tipcss.fontSize = tipFontSize;
		tipcss.color = tipFontColor;
		tipcss.backgroundColor = tipBgColor;
		tipcss.borderColor = tipBorderColor;
		tipcss.borderWidth = tipBorderWidth+"px";
		tipcss.padding = tipPadding+"px";
		tipcss.borderStyle = tipBorderStyle;
	}
	if (tooltip&&tipFollowMouse) {
		if (ns4) document.captureEvents(Event.MOUSEMOVE);
		document.onmousemove = trackMouse;
	}
}

window.onload = initTip;

var t1,t2;	// for setTimeouts
var tipOn = false;	// check if over tooltip link
function doTooltip(evt,num) {

	if (!tooltip) return;
	if (t1) clearTimeout(t1);	if (t2) clearTimeout(t2);
	tipOn = true;
	// set colors if included in messages array
	if (messages[num][1])	var curBgColor = messages[num][1];
	else curBgColor = tipBgColor;
	if (messages[num][2])	var curFontColor = messages[num][2];
	else curFontColor = tipFontColor;
	if (ns4) {
		var tip = '<table bgcolor="' + tipBorderColor + '" width="' + tipWidth + '" cellspacing="0" cellpadding="' + tipBorderWidth + '" border="0"><tr><td><table bgcolor="' + curBgColor + '" width="100%" cellspacing="0" cellpadding="' + tipPadding + '" border="0"><tr><td>'+ startStr + '<span style="font-family:' + tipFontFamily + '; font-size:' + tipFontSize + '; color:' + curFontColor + ';">' + messages[num][0] + '</span>' + endStr + '</td></tr></table></td></tr></table>';
		tooltip.write(tip);
		tooltip.close();
	} else if (ie4||ie5||ns5) {
		var tip = startStr + '<span style="font-family:' + tipFontFamily + '; font-size:' + tipFontSize + '; color:' + curFontColor + ';">' + messages[num][0] + '</span>' + endStr;
		tipcss.backgroundColor = curBgColor;
	 	tooltip.innerHTML = tip;
	}
	if (!tipFollowMouse) positionTip(evt);
	else t1=setTimeout("tipcss.visibility='visible'",100);
}

var mouseX, mouseY;
function trackMouse(evt) {
	mouseX = (ns4||ns5)? evt.pageX: window.event.clientX + document.body.scrollLeft;
	mouseY = (ns4||ns5)? evt.pageY: window.event.clientY + document.body.scrollTop;
	if (tipOn) positionTip(evt);
}

function positionTip(evt) {
	if (!tipFollowMouse) {
		mouseX = (ns4||ns5)? evt.pageX: window.event.clientX + document.body.scrollLeft;
		mouseY = (ns4||ns5)? evt.pageY: window.event.clientY + document.body.scrollTop;
	}
	// tooltip width and height
	var tpWd = (ns4)? tooltip.width: (ie4||ie5)? tooltip.clientWidth: tooltip.offsetWidth;
	var tpHt = (ns4)? tooltip.height: (ie4||ie5)? tooltip.clientHeight: tooltip.offsetHeight;
	// document area in view (subtract scrollbar width for ns)
	var winWd = (ns4||ns5)? window.innerWidth-20+window.pageXOffset: document.body.clientWidth+document.body.scrollLeft;
	var winHt = (ns4||ns5)? window.innerHeight-20+window.pageYOffset: document.body.clientHeight+document.body.scrollTop;
	// check mouse position against tip and window dimensions
	// and position the tooltip 
	if ((mouseX+offX+tpWd)>winWd) 
		tipcss.left = (ns4)? mouseX-(tpWd+offX): mouseX-(tpWd+offX)+"px";
	else tipcss.left = (ns4)? mouseX+offX: mouseX+offX+"px";
	if ((mouseY+offY+tpHt)>winHt) 
		tipcss.top = (ns4)? winHt-(tpHt+offY): winHt-(tpHt+offY)+"px";
	else tipcss.top = (ns4)? mouseY+offY: mouseY+offY+"px";
	if (!tipFollowMouse) t1=setTimeout("tipcss.visibility='visible'",100);
}

function hideTip() {
	if (!tooltip) return;
	t2=setTimeout("tipcss.visibility='hidden'",100);
	tipOn = false;
}
