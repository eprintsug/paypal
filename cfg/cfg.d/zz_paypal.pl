
$c->{paypal}->{currency} = "EUR";

$c->{paypal}->{price_for_eprint} = sub {
	my( $eprint ) = @_;
	return 100;	
};
