<html>
<head>
   <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet">
   <script src='js/jquery-3.2.1.min.js'></script>
   <style>
      .fa-context-style {
         font-size: 80px;
         color: black;
         display: inline-block;
      }
      .context-display {
         display: inline-block;
         transition: transform 0.2s;
      }
      .fa-highlight-blue {
         color: #2888a7;
      }
   </style>
</head>
<body>
   <div>
      <a href='#' class='context-display context-display-transition' onclick='return removeEntry(this, 5)' rt='0'><span class='fa fa-times fa-context-style fa-highlight-blue'></span></a>
   </div>
</body>
</html>

<script>
function removeEntry(btn, id) {
   // Do remove entry
   changeAddButton(btn, false, id);
   return false;
}
function addEntry(btn, id) {
   // Do add entry
   changeAddButton(btn, true, id);
   return false;
}
function changeAddButton(btn, isAdding, id) {
   $(btn).attr("rt", parseInt($(btn).attr("rt")) + 45);
   $(btn).css("transform", "rotate(" + parseInt($(btn).attr("rt")) + "deg)");
   if (isAdding) {
      $(btn).attr("onclick", "return removeEntry(this, " + id + ")");
      $(btn).find("span").addClass("fa-highlight-blue") // Need to add fa-highlight-blue
   } else {
      $(btn).attr("onclick", "return addEntry(this, " + id + ")");
      $(btn).find("span").removeClass("fa-highlight-blue") // Need to add fa-highlight-blue
   }
   return false;
}
</script>
