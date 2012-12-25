use strict;
use warnings;
use utf8;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Amon2::Lite;
use JSON;
require process;

our $VERSION = '0.01';

# put your configuration here
sub load_config {
	my $c = shift;

	my $mode = $c->mode_name || 'development';

}

get '/' => sub {
	my $c = shift;
	return $c->render('index.tt');
};
get '/demoui' => sub {
	my $c = shift;
	return $c->render('api.tt');
};
get '/api1-json' => sub {
	my ($c) = @_;
	my $table_name = $c->req->param('table_name');
	my $key_word = $c->req->param('key_word');
	my $postid = $c->req->param('postid');
	my $newer_than = $c->req->param('newer_than');
	my $date_equals = $c->req->param('date_equals');
	my $older_than = $c->req->param('older_than');
	my $higher_than = $c->req->param('higher_than');
	my $count_equals = $c->req->param('count_equals');
	my $lower_than = $c->req->param('lower_than');
	my $limit = $c->req->param('limit');
	if(!$table_name && $table_name != 0){
		return$c->render_json({'error' => 1, 'descript' => 'A table must be selected'});
	}
	if(($newer_than && $date_equals) || ($older_than && $date_equals)){
		return$c->render_json({'error' => 3, 'descript' => 'Cant use date_equals in combination with newer_than or older_than'});
	}
	if(($higher_than && $count_equals) || ($lower_than && $count_equals)){
		return$c->render_json({'error' => 4, 'descript' => 'Cant use count_equals in combination with higer_than or lower_than'});
	}
	return $c->render_json(process::api2($table_name, $key_word, $postid, $newer_than, $date_equals, $older_than, $higher_than, $count_equals, $lower_than, $limit));
};


# load plugins
__PACKAGE__->load_plugin('Web::CSRFDefender');
__PACKAGE__->load_plugin('Web::JSON');
__PACKAGE__->load_plugin('Web::Streaming');
__PACKAGE__->enable_session();

__PACKAGE__->to_app(handle_static => 1);


