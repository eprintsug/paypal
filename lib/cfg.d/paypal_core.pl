
# On completion of a transaction you can get a payment notification (IPN) on a callback URL
$c->{paypal}->{callback} = $c->{base_url} . '/paypal/callback';

$c->{paypal}->{button} = sub {
	my( $user, $doc ) = @_;

	my $repo = $user->repository;

	unless( defined $user && defined $doc )
	{
		return $repo->xml->create_doc_fragment;
	}

	if( $user->has_role( "editor" ) )
	{
		# direct access for admins
		return $doc->render_citation( "paypal_admin" );
	}

	my $list = $repo->dataset( "paypal_order" )->search(
		filters => [
			{ meta_fields => [qw( userid )], value => $user->get_id, match => "EX" },
			{ meta_fields => [qw( items_number )], value => $doc->get_id, match => "EX" },
		],
	);
	my @orders = $list->get_records;
	if( scalar @orders )
	{
		my $order = $orders[0];
		# 'you purchased this on...'
		return $doc->render_citation( "paypal_purchased",
			payment_date => $order->render_value( "payment_date" ),
			link => $repo->xml->render_link( $order->uri ),
		);
	}

	# render 'add to cart' button
	my( $currency, $price ) = $repo->call( [qw( paypal price )], $user, $doc );
	return $doc->render_citation( "paypal_button", 
		currency => [ $currency, "STRING" ],
		price => [ $price, "STRING" ],
		userid => [ $user->get_id, "STRING" ],
	);
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
		{ name => "userid", type => "itemref", datasetid => "user", required => 1 },
	);
}

sub get_dataset_id { "paypal_order" }

} # end package
