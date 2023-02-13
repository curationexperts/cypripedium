$(document).on('turbolinks:load', function(){
	var YOUR_MESSAGE_STRING_CONST = "Do you want to receive email nofitications when new articles are published?";
      $('#btnUserCollections').on('click', function(e){
    		confirmDialog(YOUR_MESSAGE_STRING_CONST, function(){
				var user_collections = new Array();
					$.each($("input[name='user_collections']:checked"), function() {
					user_collections.push($(this).attr('id'));
				});
				$.ajax({
					type: 'post',
					url: '/user_collections',
					data: { email: $('input#email').val(), collections: user_collections }
				}).done(function(response) {
					alert(response.message)
				}).fail(function(err) {
					alert('not ok')
				});
    		});
    	});

        function confirmDialog(message, onConfirm){
    	    var fClose = function(){
    			  modal.modal("hide");
    	    };
    	    var modal = $("#confirmModal");
    	    modal.modal("show");
    	    $("#confirmMessage").empty().append(message);
    	    $("#confirmOk").unbind().one('click', onConfirm).one('click', fClose);
    	    $("#confirmCancel").unbind().one("click", fClose);
        }
});