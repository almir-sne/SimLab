$(function() {
    var cache = {};
    $("#cartao_tags_string").autocomplete({
        minLength: 1,
        source: function(request, response) {
            var term = request.term.split(/[,][ ]*/).pop();
            if (term == "") {
                return;
            }
            if (term in cache) {
                response(cache[ term ]);
                return;
            }

            $.getJSON("/cartoes/tags", {term: term}, function(data, status, xhr) {
                if (data == "erro")
                    return;
                cache[ term ] = data;
                response(data);
            });
        },
        focus: function() {
          // prevent value inserted on focus
          return false;
        },
        select: function( event, ui ) {
          var terms = this.value.split(", ");
          // remove the current input
          terms.pop();
          // add the selected item
          terms.push( ui.item.value );
          // add placeholder to get the comma-and-space at the end
          terms.push( "" );
          this.value = terms.join( ", " );
          return false;
        }
    });
});