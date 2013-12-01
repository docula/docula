$(function() {

    $('#content').lyme({
        onMarkupChange: function(markup, html) {
            console.log(markup, html);
        },

        plugins: [
            new $.fn.lyme.plugins.AjaxAdapter(window.location.href + '?format=raw', '/test')
        ]

    });

});