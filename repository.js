/*
January, 2011

Franziska Hinkelmann
Javascript file for Repository site.
*/


$(document).ready(function()
{
	$('#header').load('/header.html');
	$('.navigation').load('/navigation.html');
	$('#footer').load('/footer.html');
 	
	$(".model").click( function() {
		//alert ('/models/' + $(this).attr('id') + '.html');
		$('#model').load('/models/' + $(this).attr('id') + '.html');
	})
	
	
/*		<li><a href="#" id="PhageLambda" class="model">Logical Model of Phage Lambda</a>

		</li>
		<li><a href="#" id="ERK" class="model">Petri Net of ERK Pathway</a>
		</li>
		<li><a href="#" id="LacO" class="model">Boolean Model of Lac Operon</a>
		</li>
		<li><a href="#" id="hrpRegulon" class="model">Boolean Model of the Pseudomonas syringae hrp Regulon</a>
		<li><a href="#" id="drosophila" class="model">Boolean Model of segment
	  polarity genes in Drosophila melanogaster</a>
		</li>
		<li><a href="#" id="Tcell" class="model">Boolean Model including relevant
	  genes or transcription factors for Th1 Th2 cell differentiation</a>
		</li>
*/
	
})    
