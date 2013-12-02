$(document).ready(function() {

    $('body').on('click', 'a.edit', function() {
        $.get(window.location.href, {'format': 'raw'}, function(data) {
            // var textarea = $('');
        });
    });

    $('body').on('submit', 'form.markdown', function() {
        console.log('Submitting markdown form to ' + window.location.pathname + '/save');

        $.post(window.location.pathname + '/save', $(this).serialize(), function(data) {
            var $html = $(data).find('div.markdown-html');
            console.log('New HTML from server: ' + $html);
            $('div.markdown-html').replaceWith($html);
        });

        return false;
    })
});
