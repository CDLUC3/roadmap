$(document).ready(function(){
  // Form submit button is disabled until all requirements are met
  $(".form-submit").prop("disabled", true);
  $("#available-templates").hide();

  // retrieve the template options and toggle the submit button on page reload
	handleComboboxChange();
	handleCheckboxClick("org", $("#plan_no_org").prop("checked"));
	handleCheckboxClick("funder", $("#plan_no_funder").prop("checked"));
	
  // When the hidden org and funder id fields change toogle the submit button
  $("#plan_org_id, #plan_funder_id").change(function(){
    handleComboboxChange();
  });

	$(".js-combobox").keyup(function(){
		var whichOne = $(this).prop('id').split('_')[1];
		$("#plan_no_" + whichOne).prop("checked", false);
	});

  // If the user clicks the no Org/Funder checkbox disable the dropdown 
	// and hide clear button
  $("#plan_no_org, #plan_no_funder").click(function(){
		var whichOne = $(this).prop('id').split('_')[2];
		handleCheckboxClick(whichOne, this.checked);
  });
});

// Only display the submit button if the user has made each decision
// -------------------------------------------------------------
function handleComboboxChange(){
  // If the (no_org checkbox is checked OR an org was selected) AND
  //        (no_funder checkbox is checked OR a funder was selected)
  var retrieve = ($("#plan_no_org").prop("checked") || 
                  $("#plan_org_id").val().trim().length > 0) &&
                 ($("#plan_no_funder").prop("checked") || 
                  $("#plan_funder_id").val().trim().length > 0);

  $("#available-templates").fadeOut();
  $("#plan_template_id").val("");
  
  if(retrieve){
		$(".form-submit").prop('disabled', false);
		
    // If the templates section isn't available then submit the form to find the template options
    if($("#available_templates").html() == undefined){
      $("form").submit();
    }
		
  }else{
  	$(".form-submit").prop('disabled', true);
  }
}

// Clear the combobox and disable it if the box was checked
// -------------------------------------------------------------
function handleCheckboxClick(name, checked){
	$("#plan_" + name + "_name").prop("disabled", checked);
	if(checked){
		$("#plan_" + name + "_name").val("");
		$("#plan_" + name + "_id").val("").change();
		$("#plan_" + name + "_name").siblings(".combobox-clear-button").hide();
	}else{
		$(".form-submit").prop('disabled', true);
	}
}