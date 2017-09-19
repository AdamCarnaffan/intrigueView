// Auto Select the First sort order for default sorting
var pastSelect;
var loginIsOpen = false;
selectSort("sortDef1");

function openLogin() {
  var loginBox = document.getElementById("loginDialog");
  if (loginIsOpen) {
    loginBox.style.left = "100%";
    loginIsOpen = false;
  } else {
    loginBox.style.left = "86%";
    loginIsOpen = true;
  }
  return false;
}

function selectSort(elementId) {
  // DRAWING & VISUALS
  if (pastSelect != null) {
    var removeTarget = document.getElementById(pastSelect);
    removeTarget.classList.remove("active");
  }
  var selected = document.getElementById(elementId);
  selected.classList.add("active");
  pastSelect = elementId;
  // RESORTING
  
  
  
  return false;
}
