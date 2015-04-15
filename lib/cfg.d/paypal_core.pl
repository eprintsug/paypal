
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

# orders are a subobject of user
$c->add_dataset_field( "user", { name => "paypal_orders", type=>"subobject", datasetid=>"paypal_order", multiple=>1, text_index=>1, dataobj_fieldname=>"eprintid" } );

$c->{datasets}->{paypal_order} = {
	class => "EPrints::DataObj::PaypalOrder",
	sqlname => "paypal_order",
	name => "paypal_order",
	columns => [qw( tx_id payment_date num_cart_items )],
	index => 1,
	import => 1,
#	search => {
#		simple => {
#			search_fields => [],
#		},
#	},
};

# https://developer.paypal.com/docs/classic/ipn/integration-guide/IPNandPDTVariables/
push @{ $c->{paypal}->{profile} },
{ name => "txn_id", type => "text" },
{ name => "payer_email", type => "email" },
{ name => "items", type => "compound", multiple => 1, fields => [
	{ sub_name => "name", type => "text" },
	{ sub_name => "number", type => "text" },
	{ sub_name => "gross", type => "text" },
]},
{ name => "num_cart_items", type => "int" },
{ name => "payment_date", type => "date" },
{ name => "mc_currency", type => "text" },
{ name => "mc_gross", type => "text" },
{ name => "_raw", type => "longtext" },
;

for(  @{ $c->{paypal}->{profile} } )
{
	$c->add_dataset_field( "paypal_order", $_ );
}

{
package EPrints::DataObj::PaypalOrder;

sub get_system_field_info
{
	return (
		{ name => "eprintid", type => "itemref", datasetid => "eprint", required => 1 },
	);
}

sub get_dataset_id { "paypal_order" }

} # end package
