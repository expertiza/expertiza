$(function() {
    $('.review-rating').each(function(index, el) {
        var $El = $(el);
        $El.barrating({
            theme: 'fontawesome-stars',
            initialRating: $El.attr('data-current-rating'),
            showSelectedRating: true,
        });
    });
    $('select').barrating('show');
});