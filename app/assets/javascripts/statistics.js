$(document).on('turbolinks:load', function(){
    $("[id^=stat_collapse_]").on("hide.bs.collapse", function(event){
        event.stopPropagation()
        let id = $(this).attr('id')
        let collection_name = id.replace('stat_collapse_', '')
        let html = $("#stat_collapse_btn_"+collection_name).html().trimEnd()
        let num = html.match(/[0-9]+$/g)
        if (!num) {
            num = ''
        }
        $("#stat_collapse_btn_"+collection_name).html('<span class="glyphicon glyphicon-plus" style="font-weight:normal; font-size:10px;"></span> ' + num);
    });

    $("[id^=stat_collapse_]").on("show.bs.collapse", function(event){
        event.stopPropagation()
        let id = $(this).attr('id')
        let collection_name = id.replace('stat_collapse_', '')
        let html = $("#stat_collapse_btn_"+collection_name).html().trimEnd()
        let num = html.match(/[0-9]+$/g)
        if (!num) {
            num = ''
        }
        $("#stat_collapse_btn_"+collection_name).html('<span class="glyphicon glyphicon-minus" style="font-weight:normal; font-size:10px;"></span> ' + num);
    });
});