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

function openInNewTab(url) {
  var tab = window.open(url, '_blank');
  tab.focus();
  console.log("hey");
  return false;
}

function beginSearch() {
  search = $('#search-input').val();
  if (search.length > 0) {
    entriesDisplayed = 0;
    $.post({
      url: "fetchEntries.php",
      data: {
        'selection': 51,
        'currentDisplay': entriesDisplayed,
        'search': search
      },
      success: function (data) {
        $('#feed-view').html(data);
        entriesDisplayed = 51;
      },
      alert: "Success!"
    });
  }
  return false;
}
