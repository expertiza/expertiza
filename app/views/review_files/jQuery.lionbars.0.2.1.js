// LionBars 0.2
// Author: Nikolay Dyankov
// www.nikolaydyankov.com
// Contact me at: me@nikolaydyankov.com
//
// ====================================
//
// I developed LionBars in my very 
// limited free time. If you have found
// this script to be useful, I would 
// very much appreciate a donation.
//
// For more information - 
// www.nikolaydyankov.com/lionbars 

(function( $ ) {
	$.fn.lionbars = function(color, showOnMouseOver, visibleBar, visibleBg) {
	  alert('test works!');
		var targets = $(this);
		var counter = 0;
		
		targets.each(function() {
			var target = $(this);
			var scrollbars = needScrollbars(target);
			counter += 1;
			
			if (scrollbars != 0) {
				wrapContent(target, counter);
				applyScrollbars(target, scrollbars[0], scrollbars[1], scrollbars[2]);
				setScrollFactor(target);
			}
		});
		
		// set event listeners ------------------------------------------------
		var scrollbarV, scrollbarH, offsetV, offsetH;
		var timeout = false, currentTarget=0, factorV, factorH;
		var drag=false, initDrag=false, dragTarget, nWrapTarget, initScrollX, initScrollY, initX, initY, mouseX, mouseY;
		var over=false, nWrapOver=true;
		
		$('.nWrap').mouseover(function() {
			if (showOnMouseOver) {
				$(this).siblings('.scrollbar').stop().animate({ "opacity" : 1 }, 200);
			}
		});
		
		$('.nWrap').mouseout(function() {
			var target = $(this);
			if (!timeout && !drag) {
				timeout = true;
				setTimeout(function() {
					currentTarget = 0;
					timeout = false;
					
					if (showOnMouseOver) {
						$('.nbar').stop().animate({ "opacity" : 0 }, 400);
					}
					
					if (!showOnMouseOver && visibleBar) {
						target.siblings('.scrollbar_bg').stop().animate({ "opacity" : 0 }, 400);
					}
				}, 1000);
			}
		});
		
		$('.nWrap').scroll(function(e) {
			if (!drag) {
				if ($(currentTarget).attr('id') != $(this).attr('id')) {
					currentTarget = $(this);
					if (!visibleBar) {
						currentTarget.siblings('.scrollbar').stop().animate({ "opacity" : 1 }, 200);
					}
					factorV = currentTarget.attr('scrollfactorV');
					factorH = currentTarget.attr('scrollfactorH');
					scrollbarV = currentTarget.siblings('.scrollbar.vertical');
					scrollbarH = currentTarget.siblings('.scrollbar.horizontal');
				}
				
				offsetV = currentTarget.scrollTop() * factorV;
				offsetV = (offsetV < 2) ? 2 : offsetV;
				scrollbarV.css({ "top" : offsetV });
				
				offsetH = currentTarget.scrollLeft() * factorH;
				offsetH = (offsetH < 2) ? 2 : offsetH;
				scrollbarH.css({ "left" : offsetH });
				
				if (!timeout && !visibleBar) {
					timeout = true;
					setTimeout(function() {
						currentTarget = 0;
						timeout = false;
						$('.nbar').stop().animate({ "opacity" : 0 }, 400);
					}, 1000);
				}
			}
		});
		
		$('.scrollbar').mouseover(function(e) {
			target = $(this);
			if (!visibleBg) {
				target.siblings('.scrollbar_bg').stop().animate({ "opacity" : 1 }, 400);
			}
			if (!visibleBar) {
				target.add(target.siblings('.scrollbar')).stop().animate({ "opacity" : 1 }, 400);
			}
			over=true;
		});
		
		$('.scrollbar').mouseout(function(e) {	
			over = false;
			if (!timeout && !drag) {
				timeout = true;
				setTimeout(function() {
					timeout = false;
					if (!over && !visibleBar) {
						$('.nbar').stop().animate({ "opacity" : 0 }, 400);
					} else if (!over && !visibleBg) {
						$('.scrollbar_bg').stop().animate({ "opacity" : 0 }, 400);					
					}
				}, 1000);
			}
		});
		
		$('.scrollbar').mousedown(function(e) {
			e.preventDefault();
			drag = true;
			dragTarget = $(this);
			initX = e.pageX;
			initY = e.pageY;
			initScrollX = $(this).position().left;
			initScrollY = $(this).position().top;
		});
		
		$(document).mousemove(function(e) {
			if (drag && !initDrag) {
				initDrag = true;
				nWrapTarget = dragTarget.siblings('.nWrap');
				factorH = nWrapTarget.attr('scrollfactorh');
				factorV = nWrapTarget.attr('scrollfactorv');
			}
			if (drag) {
				mouseX = e.pageX;
				mouseY = e.pageY;
				dragScrollbar(dragTarget, nWrapTarget, e, factorV, factorH, initScrollX, initScrollY, initX, initY, mouseX, mouseY);
			}
		});
		
		$(document).mouseup(function(e) {
			if (drag) {
				drag = false;
				initDrag = false;
				if (!timeout && !drag) {
					timeout = true;
					setTimeout(function() {
						timeout = false;
						if (!over && !visibleBar) {
							$('.nbar').stop().animate({ "opacity" : 0 }, 400);
						} else if (!over && !visibleBg) {
							$('.scrollbar_bg').stop().animate({ "opacity" : 0 }, 400);					
						}
					}, 1000);
				}
			}
		});
		
		// ================== UTILITY FUNCTIONS ====================
		// =========================================================		
		function dragScrollbar(targetScrollbar, nWrapTarget, e, factorV, factorH, initScrollX, initScrollY, initX, initY, mouseX, mouseY) {
			var offsetX, offsetY, realOffsetX, realOffsetY;
			if (targetScrollbar.hasClass('vertical')) {
				realOffsetY = initScrollY + mouseY - initY;
				offsetY = realOffsetY;
				offsetY = (offsetY < 2) ? 2 : offsetY;
				offsetY = (offsetY > targetScrollbar.siblings('.scrollbar_bg.vertical').height() - targetScrollbar.height()+2) ? targetScrollbar.siblings('.scrollbar_bg.vertical').height() - targetScrollbar.height()+2 : offsetY;
				targetScrollbar.css({ "top" : offsetY });
				nWrapTarget.scrollTop(realOffsetY / factorV);
			} else {
				realOffsetX = initScrollX + mouseX - initX;
				offsetX = realOffsetX;
				offsetX = (offsetX < 2) ? 2 : offsetX;
				offsetX = (offsetX > targetScrollbar.siblings('.scrollbar_bg.horizontal').width() - targetScrollbar.width()+2) ? targetScrollbar.siblings('.scrollbar_bg.horizontal').width() - targetScrollbar.width()+2 : offsetX;
				targetScrollbar.css({ "left" : offsetX });
				nWrapTarget.scrollLeft(realOffsetX / factorH);
			}
		}
		
		function setScrollFactor(target) {
			var target = $(target);
			var nWrap = target.find('.nWrap');
			
			if (nWrap.hasClass('hscroll')) {
				var scrollbarV = nWrap.siblings('.scrollbar.vertical');
				var scrollfactorV = (target.height()-9 - scrollbarV.height()-2) / (nWrap[0].scrollHeight-target.height());
			} else {
				var scrollbarV = nWrap.siblings('.scrollbar.vertical');
				var scrollfactorV = (target.height() - scrollbarV.height()-2) / (nWrap[0].scrollHeight-target.height());
			}
			nWrap.attr('scrollfactorV', scrollfactorV);
			
			if (nWrap.hasClass('vscroll')) {
				var scrollbarH = nWrap.siblings('.scrollbar.horizontal');				
				var scrollfactorH = (target.width()-9 - scrollbarH.width()-2) / (nWrap[0].scrollWidth-target.width());
			} else {
				var scrollbarH = nWrap.siblings('.scrollbar.horizontal');
				var scrollfactorH = (target.width() - scrollbarH.width()-2) / (nWrap[0].scrollWidth-target.width());
			}
			nWrap.attr('scrollfactorH', scrollfactorH);	
		}
		
		function applyScrollbars(target, scrollbars, width, height) {
			var scrollbarV = '<div class="scrollbar vertical nbar"></div><div class="scrollbar_bg vertical nbar"></div>';
			var scrollbarH = '<div class="scrollbar horizontal nbar"></div><div class="scrollbar_bg horizontal nbar"></div>';	
			var target = $(target);
			var nWrap = target.find('.nWrap');
			
			// append scrollbars
			if (scrollbars == 1) {
				target.prepend(scrollbarV);
				nWrap.css({ "width" : nWrap.width()+width });
				nWrap.addClass('vscroll');
			}
			
			if (scrollbars == 2) {
				target.prepend(scrollbarH);
				nWrap.css({ "height" : nWrap.height()+height });
				nWrap.addClass('hscroll');
			}
			
			if (scrollbars == 3) {
				target.prepend(scrollbarV);
				target.prepend(scrollbarH);
				nWrap.css({ "width" : nWrap.width()+width });
				nWrap.css({ "height" : nWrap.height()+height });
				nWrap.addClass('vscroll');
				nWrap.addClass('hscroll');
			}
			
			// calculate the dimentions of the scrollbars & set width and height
			var minLength = 25;
			var fullHeight = target.find('.nWrap')[0].scrollHeight;
			var fullWidth = target.find('.nWrap')[0].scrollWidth;	
			var realHeight = target.height();
			var realWidth = target.width();
			
			if (nWrap.hasClass('vscroll')) {
				fullWidth = fullWidth + 15;
			}
		
			if (nWrap.hasClass('hscroll')) {
				fullHeight = fullHeight + 15;
			}
		
			var height = realHeight * (realHeight / fullHeight);
			var width = realWidth * (realWidth / fullWidth);
			
			height = (height < minLength) ? minLength : height;
			width = (width < minLength) ? minLength : width;
			
			target.find('.scrollbar.vertical').css({ "height" : height });
			target.find('.scrollbar.horizontal').css({ "width" : width });
			
			// fix scrollbar backgrounds
			if (nWrap.hasClass('hscroll')) {
				target.find('.scrollbar_bg.vertical').css({ "height" : target.find('.scrollbar_bg.vertical').height()-13 });
			} else {
				target.find('.scrollbar_bg.vertical').css({ "height" : target.find('.scrollbar_bg.vertical').height()-4 });
			}
			
			if (nWrap.hasClass('vscroll')) {
				target.find('.scrollbar_bg.horizontal').css({ "width" : target.find('.scrollbar_bg.horizontal').width()-13 });
			} else {
				target.find('.scrollbar_bg.horizontal').css({ "width" : target.find('.scrollbar_bg.horizontal').width()-4 });
			}
			
			// apply 'light' class if needed
			if (color == 'light') {
				target.find('.scrollbar').addClass('light');
				target.find('.scrollbar_bg').addClass('light');
			} else {
				target.find('.scrollbar').addClass('dark');
				target.find('.scrollbar_bg').addClass('dark');
			}
			
			// param: visibleBar, visibleBg
			if (visibleBar) {
				target.find('.scrollbar').css({ "opacity" : 1 });
			}		
			if (visibleBg) {

				target.find('.scrollbar_bg').css({ "opacity" : 1 });
			}
		}
		
		function needScrollbars(target) {
			var info = new Array();
			var val=0;
			var target = $(target);
			var width, height;
			
			target.css({ "overflow" : 'auto' }); // 1.2
			target.prepend('<div class="nCheck"></div>');
			
			// check if the target needs vertical scrollbar
			target.find('.nCheck').css({ "width" : '100%', "height" : 1, "opacity" : 1, "background" : 'red' });		
			if (target.width() > target.find('.nCheck').width()) {
				val = val + 1;
				width = target.width() - target.find('.nCheck').width();
			}
			
			// check if the target needs horizontal scrollbar	
			target.find('.nCheck').css({ "width" : 1, "height" : '100%' });
			if (target.height() > target.find('.nCheck').height()) {
				val = val + 2;
				height = target.height() - target.find('.nCheck').height();
			}
			
			// clean up
			target.find('.nCheck').remove();
			
			// 0 = doesn't need scrollbars
			// 1 = vertical scrollbar only
			// 2 = horizontal scrollbar only
			// 3 = both scrollbars
			return [val, width, height];
		}
		
		function wrapContent(target, id) {
			var target = $(target);
			
			content = target.html();
			
			target.html('');
			target.append('<div class="nWrap" id="'+id+'"></div>');
			
			nWrap = target.find('.nWrap');
			$(nWrap).html(content);
			
			var paddingTop = target.css('padding-top');
			var paddingRight = target.css('padding-right');			
			var paddingBottom = target.css('padding-bottom');
			var paddingLeft = target.css('padding-left');
			
			paddingTop = parseInt(paddingTop.replace('px', ''));
			paddingRight = parseInt(paddingRight.replace('px', ''));
			paddingBottom = parseInt(paddingBottom.replace('px', ''));
			paddingLeft = parseInt(paddingLeft.replace('px', ''));
		
			target.css({
				"padding" : 0,
				"width" : target.width() + paddingLeft + paddingRight,
				"height" : target.height() + paddingTop + paddingBottom,
				"overflow" : 'hidden',
				"position" : 'relative'
			});
		
			nWrap.css({
				"padding-top" : paddingTop,
				"padding-left" : paddingLeft,
				"padding-bottom" : paddingBottom,
				"padding-right" : paddingRight,
				"width" : target.width() - paddingLeft - paddingRight,
				"height" : target.height() - paddingTop - paddingBottom,
			});
		}
		
		
		return this.each(function(){
			var $this = $(this);
		});
	};
})( jQuery );