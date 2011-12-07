$(document).ready(function() {
    $('#header').load("/header.html");
    $('#footer').load("/footer.html");
    $('.nav').load("/navigation.html");
    $('.input').hide();
    $('.explain').hide();
    
    var choiceBox = $("input[name='choice_box']:checked").val();
    changeChoiceBox(choiceBox);
    
    $("input[name='choice_box']").change(function() {
        changeChoiceBox($("input[name='choice_box']:checked").val());
    });
    
    $("input[name='inputType']").change(function() {
        changeModelType($("input[name='inputType']:checked").val());
    });
    
    $("input[name='anaysis_method']").change(function() {
        changeAnalysisType($("input[name='anaysis_method']:checked").val());
    });
    
    $("#p_value").change(function() {
        changeChoiceBox($("input[name='choice_box']:checked").val());
    });

    
    var filepmname = "";
    
    var file = "";
    $('#upload_file').uploadify({
	'uploader': '/uploadify/uploadify.swf',
        'script': '/uploadify/uploadify.php',
	'cancelImg': '/uploadify/cancel.png',
        'folder': '/../../htdocs/no-ssl/files',
	'auto': false,
        'multi': false,
	'removeCompleted' : true,
        'onSelect': function(event, ID, fileObj) {
            file = fileObj.name;
            //alert('The file ' + fileObj.name + ' was added to the queue.');
        },
        'onComplete': function() {
            //alert('Complete');
            postForm("&upload_file=" + file + filepmname);
            file = "";
        },
        'onCancel': function() {
            file = "";
        }, 
	'onError': function() {
	    alert( "ERROR");
	}
    });

    // filePM is for propensity matrix in SDDS
    var filePM = "";
    $('#upload_file_pm').uploadify({
	'uploader': '/uploadify/uploadify.swf',
        'script': '/uploadify/uploadify.php',
	'cancelImg': '/uploadify/cancel.png',
        //'folder': '/../../htdocs/no-ssl/files',
        'folder': '/Documents/htdocs/no-ssl/files',
	'auto': false,
        'multi': false,
	'removeCompleted' : true,
        'onSelect': function(event, ID, fileObj) {
            filePM = fileObj.name;
            //alert('The file ' + fileObj.name + ' was added to the queue.');
        },
        'onComplete': function() {
            //alert('Complete');
            filepmname = "&upload_file_pm=" + filePM;
            filePM = "";
        },
        'onCancel': function() {
            filePM = "";
        }, 
	'onError': function() {
	    alert( "ERROR");
	}
    });
    
    $('button').click(function() {
        $("#result").html("Calculating...");
	
	var files_param = "";

	if (filePM != "") {
	    //alert( filePM );
        $('#upload_file_pm').uploadifyUpload();
	}

        if (file != "") {
            //alert( file );
            $('#upload_file').uploadifyUpload();
        } else {
            //alert(formdata);
            postForm("");
        }
    });
});

function postForm(file) {
    var formdata = $("form").serialize();
    formdata = formdata + file;
    //alert(formdata);
    //console.log(formdata);
    $.post("../../cgi-bin/git/adam.pl", formdata, function(data) {
        $("#result").html(data);
        //alert(data);
    });
};

function changeChoiceBox(choiceBox) {
    $('.input').hide();
    $('.explain').hide();
    
    $('#sdds_entries').hide();
    
    $('#inputArea').show();
    $('#explain_mi').show();

    // show explanation for choice selected
    $("#explain_" + choiceBox).show(); 
    $("#explain_mt_" + choiceBox).show(); 
    var sampleInput;
    if (choiceBox == "build") {
        $('#build').show();
        $('.pvalue').show();
        $('#e_build').show();
        sampleInput = 'A(t) \tB(t) \tC(t+1)\n0\t0\t0 \n0\t1\t0 \n1\t0\t0 \n1\t1\t1';
    } else if (choiceBox == "analyze") {
        $('#analyze').show();
        $('.option').show();
        var modelType = $("input[name='inputType']:checked").val();
        sampleInput = changeModelType(modelType);
    } else if (choiceBox == "control") {
        $('#control').show();
        $('.pvalue').show();
        sampleInput = 'f1 = x13*x15*x18*x19*x20+x13*x15*x18*x19+x13*x15*x18*x20+x13*x15*x19*x20+x13*x18*x19*x20+x15*x18*x19*x20+x13*x15*x18+x13*x15*x19+x13*x18*x19+x15*x18*x19+x13*x15*x20+x13*x18*x20+x15*x18*x20+x13*x19*x20+x15*x19*x20+x18*x19*x20+x13*x15+x13*x18+x15*x18+x13*x19+x15*x19+x18*x19+x13*x20+x15*x20+x18*x20+x19*x20+x13+x15+x18+x19+x20\nf2 =  x3*x4*x5+x3*x4+x4*x5+x4\nf3 = x2*x10*x12+x2*x10+x2*x12+x10*x12+x2+x10+x12+1\nf4 = x1*x9*x10*x12+x1*x9*x12+x9*x10*x12\nf5 = x2*x6*x10*x12+x2*x6*x10+x2*x6*x12+x2*x10*x12+x6*x10*x12+x2*x6+x2*x10+x6*x10+x2*x12+x6*x12+x10*x12+x2+x6+x10+x12+1\nf6 = x3*x5*x7+x3*x7+x5*x7+x7\nf7 = x12\nf8 = x2*x11\nf9 = x1*x10+x1+x10\nf10 = x13*x15*x18*x19*x20+x13*x15*x18*x19+x13*x15*x18*x20+x13*x15*x19*x20+x13*x18*x19*x20+x15*x18*x19*x20+x13*x15*x18+x13*x15*x19+x13*x18*x19+x15*x18*x19+x13*x15*x20+x13*x18*x20+x15*x18*x20+x13*x19*x20+x15*x19*x20+x18*x19*x20+x13*x15+x13*x18+x15*x18+x13*x19+x15*x19+x18*x19+x13*x20+x15*x20+x18*x20+x19*x20+x13+x15+x18+x19+x20\nf11 = x4\nf12 = x1*x9*x10+x1*x9+x1*x10+x9*x10+x1+x9+x10\nf13 = x9*x10*x18+x9*x10+x9*x18+x10*x18+x9+x10\nf14 = 1\nf15 = x14\nf16 = x14\nf17 = x14\nf18 = x16*x17\nf19 = x15*x16\nf20 = x15*x17';
    } else {
        jQuery.error = console.error;
        jquery.error("wrong choice");
        return 1;
    }
    $('#inputArea').val(sampleInput);
    
    
    var simulationType = $("input[name='anaysis_method']:checked").val();
    changeAnalysisType(simulationType);
};

function changeModelType(type) {
    $('.optionfield').hide();
    $('.explain.type').hide();
    
    $('#file_exp_sdds').hide();
    $('#sdds_entries').hide();
    $('#explain_mi_sdds').hide();
    $('#sdds_graph').hide();
    $('#SteadyStates').hide();
    $('#TransitionMatrix').hide();

    $("#explain_" + type).show(); 
    $('#inputArea').show();
    $('#explain_mi').show();
    $('#Simulation').show();

    var pval = parseInt($('#p_value').val());
    var sampleInput;
    if (type == 'PDS') {
        $('.pvalue').show();
        sampleInput = 'f1 = x1+x2\nf2 = x1*x2*x3\nf3 = x1*x2+x3^2';
        if (pval == 2) {
            $('#conjunctive').show();
            $('#feedback').show();
        }
	$('#Algorithms').show();
    } else if (type == 'pPDS') {
        $('.pvalue').show();
        $('#probabilities').show();
	$('input[name="anaysis_method"][value="Simulation"]').attr('checked', true);
        sampleInput = 'f1 = { \n  x1+x2   #.9 \n  x1      #.1\n}\nf2 = x1*x2*x3 \nf3 = { \n  x1*x2+x3^2 \n  x2 \n}';
    } else if (type == 'BN') {
        $('#conjunctive').show();
	$('#Algorithms').show();
        $('#feedback').show();
        sampleInput = 'f1 = (x1+x2)\nf2 = ((x1*x2)*x3)\nf3 = ((x1*x2)+x3)';
    } else if (type == 'Petrinet') {
        $('#kbound').show();
	$('input[name="anaysis_method"][value="Simulation"]').attr('checked', true);
        sampleInput = '';
    } else if (type == 'PBN') {
	$('#Algorithms').show();
        $('#probabilities').show();
    } else if (type == 'GINsim') {
	$('#Algorithms').show();
        sampleInput = '';

    } else if (type == 'SDDS') {
	$('#inputArea').hide();
	$('#explain_mi').hide();
	$('#Simulation').hide();
	
	$('#file_exp_sdds').show();
	$('#explain_mi_sdds').show();
	$('#explain_mi_sdds').show();
	$('#sdds_graph').show();
	$('#sdds_entries').show();
	$('#SteadyStates').show();
	$('#TransitionMatrix').show();
	
	$('input[name="anaysis_method"][value="sdds_graph"]').attr('checked', true);
        sampleInput = '';
	
    } else {
        jQuery.error = console.error;
        jquery.error("wrong model type");
        return 1;
    }
    $('#inputArea').val(sampleInput);
    return sampleInput;
};


function changeAnalysisType(simulationType) {
    if (simulationType == 'Simulation') {
        $('#statespace').show();
    } else if (simulationType == 'Algorithms') {
        $('#statespace').hide();
    } else if (simulationType == 'Conjunctive') {
        //
	
    } else if (simulationType == 'sdds_graph') {
	//
	
    } else {
        jQuery.error = console.error;
        jquery.error("wrong type between simulation and algorithm");
        return 1;
    }
};
