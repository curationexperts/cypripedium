$(document).on('turbolinks:load', function(){
	var YOUR_MESSAGE_STRING_CONST = "Do you want to receive email nofitications when new articles are published?";
      $('#btnUserCollections').on('click', function(e){
			e.preventDefault();
    		confirmDialog(YOUR_MESSAGE_STRING_CONST, function(){
				var user_collections = new Array();
				$.each($("input[name='user_collections']:checked"), function() {
					user_collections.push($(this).attr('id'));
				});
				$.ajax({
					type: 'post',
					url: '/user_collection',
					data: { email: $('input#email').val(), collections: user_collections }
				}).done(function(response) {
					clearDialog()
					if(response.status == '200') {
						alertBox(response.message, 'user_collections', response.user_collections)
					}
					else {
						alertBox("Error", 'string', response.message)
					}
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
    	    $("#btnSubscribe").unbind().one('click', onConfirm).one('click', fClose);
    	    $("#confirmCancel").unbind().one("click", fClose);
        }

		function alertBox(title, datatype, message){
    	    var fClose = function(){
    			  modal.modal("hide");
    	    };
    	    var modal = $("#alertModal");
    	    modal.modal("show");
			$("#alertHead").empty().append(title);
			renderAlertBox(datatype, message);
    	    $("#alertClose").unbind().one("click", fClose);
        }

		$('button#user_subscriptions_search').click(function(e) {
			e.preventDefault();
			$.ajax({
				type: 'get',
				url: '/user_collection',
				data: { email: $('input#email').val() }
			}).done(function(response) {
				let status = response.status
				if(status == 'error') {
					alertBox('Error', 'string', response.message)
					return
				}
				try{
					let user_collections_obj = response.user_collections
					if(user_collections_obj == ''){
						return emptyUserCollections()
					}
					user_collections = jQuery.parseJSON(user_collections_obj)
					collections = user_collections.collections
					if($.isArray(collections) && collections.length > 0) {
						let subscription_list = $('ul#subscription_list')
						subscription_list.empty()
						collection_map = {}
						$("input:checkbox[name=user_collections]").each(function(){
							collection_map[$(this).attr('id')] = $(this).next('label').text()
						});
						$.each(collections, function(index, collection){
							subscription_list.append($("<li>").text(collection_map[collection.toString()]))
						})
						$('button#btnSubscribe').html('Update Subscription')
						$('button#btnUnsubscribe').show()
					}
					else {
						return emptyUserCollections()
					}
				}
				catch(err){
					alertBox('Cannot parse the user subscription information:', 'string', err.message)
				}
			}).fail(function(err) {
				alertBox('Error', 'string', err.responseText)
			});
		});

		$('button#btnUnsubscribe').click(function(e) {
			e.preventDefault();
			$.ajax({
				type: 'delete',
				url: '/user_collection',
				data: { email: $('input#email').val() }
			}).done(function(response) {
				try{
					alertBox(response.message, 'user_collections', response.user_collections)
					$('#btnUnsubscribe').hide()
					$('button#btnSubscribe').html('Subscribe')
					clearDialog()
					hideDialog()
				}
				catch(err){
					alertBox('Cannot unsubscribe user:', 'string', err.message)
				}
			}).fail(function(err) {
				alertBox('Error', 'string', err.responseText)
			});
		});

		$('a[id^=btnUnsubscribe_' + ']').on('ajax:success', function(e, data) {
			try{
				let user_collections_obj = jQuery.parseJSON(data.user_collections)
				let user_collections = user_collections_obj.collections
				if(user_collections && $.isArray(user_collections)){
					$(this).css('color', 'red');
					$(this).text('Unsubscribed')
				}
			}
			catch(err){
				alertBox(err.status + ': ' + err.statusText)
			}
		})

		$('a[id^=btnUnsubscribe_' + ']').on('ajax:error', function(err, data) {
			alertBox(data.status + ': ' + data.statusText)
		})

		function emptyUserCollections () {
			$('div#subscription_list_div').find('span').remove()
			$('div#subscription_list_div').find('ul').empty()
			$('div#subscription_list_div').append(("<span id='emptySpan'><label>You don't have any subscriptions now.</label></span>"))
		}

		function renderAlertBox(datatype, message) {
			switch (datatype) {
				case 'string':
					$("#alertBody").empty().append(message);
					break;
				case 'user_collections':
					renderUserCollections(message);
					break;
				default:
					$("#alertBody").empty().append(message);
			}
		}

		function renderUserCollections(user_collections_obj){
			user_collections = jQuery.parseJSON(user_collections_obj)
			collections = user_collections.collections
			if($.isArray(collections) && collections.length > 0) {
				collection_map = {}
				$("input:checkbox[name=user_collections]").each(function(){
					collection_map[$(this).attr('id')] = $(this).next('label').text()
				});
				let alertBody = $('div#alertBody').empty();
				let subscription_list = $('<ul>').css("list-style-type", "square")
				alertBody.append(subscription_list)
				$.each(collections, function(index, collection){
					subscription_list.append($("<li>").text(collection_map[collection.toString()]))
				})
			}
		}

		function clearDialog () {
			let subscription_list_div = $('div#subscription_list_div')
			if(subscription_list_div) {
				subscription_list_div.find('span').remove()
			}
			let user_collections_list_ul = $('ul#subscription_list')
			if(user_collections_list_ul) {
				user_collections_list_ul.empty()
			}
			$.each($("input[name='user_collections']:checked"), function() {
				$(this).prop('checked', false)
			});
		}

		function hideDialog () {
			var modal = $("#confirmModal");
    	    modal.modal("hide");
		}
});