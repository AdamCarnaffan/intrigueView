// Auto Select the First sort order for default sorting
var pastSelect;
selectSort("sortDef1");




function selectSort(elementId) {
  // DRAWING & VISUALS
  if (pastSelect != null) {
    var removeTarget = document.getElementById(pastSelect);
    //removeTarget.classList.remove("active");
  }
  var selected = document.getElementById(elementId);
  //selected.classList.add("active");
  pastSelect = elementId;
  // RESORTING



  return false;
}

function fixTree() {

}
