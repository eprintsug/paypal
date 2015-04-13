
# On completion of a transaction you can get a payment notification (IPN) on a callback URL
$c->{paypal}->{callback} = $c->{base_url} . '/paypal/callback';

# can the given user download this document (eg. administrators)
$c->{paypal}->{user_can_download} = sub {
	my( $user, $document ) = @_;

	return 0;
};

# has the given user already purchased this document
$c->{paypal}->{user_has_purchased} = sub {
	my( $user, $document ) = @_;

	return 0;
};

__DATA__

$c->{datasets}->{paypal_order} = {
	class => "EPrints::DataObj::PaypalOrder",
	sqlname => "paypal_order",
	name => "paypal_order",
	columns => [qw()],
	index => 1,
	import => 1,
	search => {
		simple => {
			search_fields => [],
		},
	},
};

# https://developer.paypal.com/docs/classic/ipn/integration-guide/IPNandPDTVariables/
# txn_id 
# payer_email
# items (name, number)
# txn_type (=cart)
# num_cart_items
# payment_date
# mc_currency
# mc_gross
# payment_status (= completed)
# receiver_email (=check)
# mc_gross_x (=check)

$c->add_dataset_field( "paypal_order", { name=>"eprintid", type=>"itemref", datasetid=>"eprint", required=>1} );
$c->add_dataset_field( "paypal_order", {} );
$c->add_dataset_field( "paypal_order", {} );
$c->add_dataset_field( "paypal_order", {} );
$c->add_dataset_field( "paypal_order", {} );
$c->add_dataset_field( "paypal_order", {} );

$c->add_dataset_field( "user", { type=>"subobject", datasetid=>"paypal_order", multiple=>1, text_index=>1, dataobj_fieldname=>"eprintid" } );

{
package EPrints::DataObj::PaypalOrder;

sub get_dataset_id { "paypal_order" }

}

