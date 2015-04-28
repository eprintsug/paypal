$c->{roles}->{paypal_buyer} = [qw{
	+paypal_order/view:owner
}];
$c->{roles}->{paypal_admin} = [qw{
	+paypal_order/view
}];
push @{ $c->{user_roles}->{user} }, qw( paypal_buyer );
push @{ $c->{user_roles}->{editor} }, qw( paypal_admin );
push @{ $c->{user_roles}->{admin} }, qw( paypal_admin );

$c->{paypal}->{button} = sub {
	my( $user, $doc ) = @_;

	my $repo = $user->repository;

	unless( defined $user && defined $doc )
	{
		return $repo->xml->create_doc_fragment;
	}

	if( $repo->call( [qw( paypal can_user_view_document )], $user, $doc ) )
	{
		# direct access for admins
		return $doc->render_citation( "paypal_admin" );
	}

	my $order = $repo->call( [qw( paypal get_order_for_document )], $user, $doc );
	if( defined $order )
	{
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

$c->{paypal}->{can_user_view_document} = sub {
	my( $user, $doc ) = @_;

	return 1 if $user->has_role( "editor" );
	return 1 if $user->has_role( "admin" );
	return 0;

};

$c->{paypal}->{get_order_for_document} = sub {
	my( $user, $doc ) = @_;

	my $repo = $user->repository;

	my $list = $repo->dataset( "paypal_order" )->search(
		filters => [
			{ meta_fields => [qw( userid )], value => $user->get_id, match => "EX" },
			{ meta_fields => [qw( items_number )], value => $doc->get_id, match => "EX" },
		],
	);

	my @orders = $list->get_records;
	return scalar @orders ? $orders[0] : undef;
};

# orders are a subobject of user
$c->add_dataset_field( "user", { name => "paypal_orders", type=>"subobject", datasetid=>"paypal_order", multiple=>1, text_index=>1, dataobj_fieldname=>"userid", dataset_fieldname => "" } );

$c->{datasets}->{paypal_order} = {
	class => "EPrints::DataObj::PaypalOrder",
	sqlname => "paypal_order",
	name => "paypal_order",
	columns => [qw( txn_id payment_date num_cart_items mc_gross )],
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
{ name => "payment_date", type => "time" },
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

our @ISA = qw( EPrints::DataObj );

sub get_system_field_info
{
	return (
		{ name => "userid", type => "itemref", datasetid => "user", required => 1 },
	);
}

sub get_dataset_id { "paypal_order" }

} # end package
