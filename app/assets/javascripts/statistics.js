$(document).on('turbolinks:load', function(){
    $("[id^=stat_collapse_]").on("hide.bs.collapse", function(){
        let id = $(this).attr('id')
        let collection_name = id.replace('stat_collapse_', '')
        let html = $("#stat_btn_"+collection_name).html()
        let num = html.match(/[0-9]+/g)
        $("#stat_btn_"+collection_name).html('<span class="glyphicon glyphicon-plus"></span> ' + num);
    });

    $("[id^=stat_collapse_]").on("show.bs.collapse", function(){
        let id = $(this).attr('id')
        let collection_name = id.replace('stat_collapse_', '')
        let html = $("#stat_btn_"+collection_name).html()
        let num = html.match(/[0-9]+/g)
        $("#stat_btn_"+collection_name).html('<span class="glyphicon glyphicon-minus"></span> ' + num);
    });
});