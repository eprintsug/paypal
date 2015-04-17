document.observe('dom:loaded', function(){
	$$(".paypal-container").each( function(el) {
		new Ajax.Request(eprints_http_cgiroot+'/paypal/button', {
			method: 'get',
			onSuccess: ( function(transport) {
				this.innerHTML = transport.responseText;
			}).bind(el),
			parameters: {
				docid: el.getAttribute( "data-docid" )
			}
		});
	});
});
