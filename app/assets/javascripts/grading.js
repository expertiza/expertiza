  function toggleAll(numteams) {
      var maintag = document.getElementById('teamAll');
      visible = maintag.innerHTML == 'Show all teams';
      if (visible) {
          maintag.innerHTML = 'Hide all teams';
      } else {
          maintag.innerHTML = 'Show all teams';
      }
      toggleTeams(numteams, visible);
  }

  function collapseObj(obj, atag, header) {
      obj.style.display = 'none';
      atag.innerHTML = '<img src="/assets/expand.png">';
      header.style.backgroundColor = 'white';
      header.style.color = "#000000";

      files = document.getElementById(obj.id + '_files');
      if (files) {
          files.style.display = 'none';
          files_tag = document.getElementById(obj.id + '_filesLink');
          if (files_tag) {
              files_tag.innerHTML = 'show submission';
          }
      }
      reviews = document.getElementById(obj.id + '_reviews');
      if (reviews) {
          reviews.style.display = 'none';
          reviews_tag = document.getElementById(obj.id + '_reviewsLink');
          if (reviews_tag) {
              reviews_tag.innerHTML = 'show reviews';
          }
      }
      mreviews = document.getElementById(obj.id + '_mreviews');
      if (mreviews) {
          mreviews.style.display = 'none';
          mreviews_tag = document.getElementById(obj.id + '_mreviewsLink');
          if (mreviews_tag) {
              mreviews_tag.innerHTML = 'show metareviews';
          }
      }
      previews = document.getElementById(obj.id + '_previews');
      if (previews) {
          previews.style.display = 'none';
          previews_tag = document.getElementById(obj.id + '_previewsLink');
          if (previews_tag) {
              previews_tag.innerHTML = 'show teammate reviews';
          }
      }
  }

  function toggleTeams(numteams, visible) {
      for (var i = 0; i < numteams; i++) {
          var sublistsize = 1;
          var elementId = 'team' + i;
          var obj = document.getElementById(elementId + '_' + sublistsize);
          var atag = document.getElementById(elementId + 'Link');
          var header = document.getElementById(elementId + '_header');
          if (atag) {
              while (obj != null) {
                  var bExpand = obj.style.display.length == 0;
                  if (bExpand) {
                      if (!visible)
                          collapseObj(obj, atag, header);
                  } else {
                      if (visible) {
                          obj.style.display = '';
                          //E1877: changes made to adjust width of expandables
                          var offsets = obj.getBoundingClientRect();
                          obj.style.width = 'calc(100vw - 103px)';
                          atag.innerHTML = '<img src="/assets/collapse.png">';
                          header.style.backgroundColor = '#a90201';
                          header.style.color = "#ffffff";
                      }
                  }
                  sublistsize += 1;
                  var obj = document.getElementById(elementId + "_" + sublistsize);
              }
          }
      }
  }

  function toggleTeam(elementId) {
      var sublistsize = 1;
      var obj = document.getElementById(elementId + '_' + sublistsize);
      var atag = document.getElementById(elementId + 'Link');
      var header = document.getElementById(elementId + '_header');
      if (atag) {
          while (obj != null) {

              header.style.backgroundColor = 'white';
              header.style.color = "#000000";
              var bExpand = obj.style.display.length == 0;
              if (bExpand) {
                  collapseObj(obj, atag);
              } else {
                  obj.style.display = '';
                  //E1877: changes made to adjust width of expandables
                  var offsets = obj.getBoundingClientRect();
                  obj.style.width = 'calc(100vw - 103px)';
                  atag.innerHTML = '<img src="/assets/collapse.png">';
                  header.style.backgroundColor = '#a90201';
                  header.style.color = "#ffffff";
              }
              sublistsize += 1;
              var obj = document.getElementById(elementId + '_' + sublistsize);
          }
      }
  }
