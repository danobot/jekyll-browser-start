
var searchOverlay = $("#searchOverlay");
var searchInput = $("#searchOverlay input");
var searchButton = $("#searchbutton");

// hide the searchOverlay and reset input on load

searchOverlay.hide();
searchInput.val('');

// Status indicating that search is not active. 
	
var searchStatus = false;

// If any key is pressed while CMD is not pressed, begin search

window.onkeydown = function (e) {
    if (!e) e = window.event;
    if (!e.metaKey) {
      if(e.keyCode >= 65 && event.keyCode <= 90 || e.keyCode >= 48 && event.keyCode <= 57) {
          if (!searchStatus) {
              searchOverlay.show();
              searchOverlay.find('input').focus();
              searchStatus = true;
              searchButton.addClass("close");
          }
      }
    }
  }

// Open and close search when magnifying class or close is tapped

searchButton.click(function() {
      if (!searchStatus) {
        searchOverlay.show();
			searchOverlay.find('input').focus();
			searchStatus = true;
			console.log("searchStatus " + searchStatus);
      }
    else  {
        searchOverlay.hide();
        searchOverlay.find('input').val('');
        searchStatus = false;
        console.log("searchStatus " + searchStatus);
        searchButton.removeClass("close");

    }
});

// Close search when ESC is pressed

$(document).keyup(function(e) {
      if (e.keyCode == 27 && searchStatus) {
        searchOverlay.hide();
        searchOverlay.find('input').val('');
        searchStatus = false;
        console.log("searchStatus " + searchStatus);
        searchButton.removeClass("close");
		 }
});

// Close search is DEL/Backspace is pressed when input is already empty

searchInput.keyup(function(e) {
    console.log(e.keyCode);
    console.log(searchInput.value);
    // if (e.keyCode == 13 && searchStatus) {
    filterSelection(searchInput[0].value);
    // }
    if (searchStatus) {
       if (!this.value) {
        searchOverlay.hide();
        searchOverlay.find('input').val('');
        searchStatus = false;
        console.log("searchStatus " + searchInput.value);
        searchButton.removeClass("close");
        }
    }
});
	
searchInput.focusout(function(e) {
  // myMove();
  searchOverlay.hide();
  searchInput.val('');
  searchStatus = false;


  
});
    
// function myMove() {
//   var elem = searchOverlay; 
//   var pos = 0;
//   var id = setInterval(frame, 1);
//   function frame() {
//     if (pos == -200) {
//       clearInterval(id);
//     } else {
//       pos-- 
//       elem.style.bottom = pos + 'px'; 
//     }
//   }
// }