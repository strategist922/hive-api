#!/usr/bin/perl
package process;
use strict;
use warnings;
use utf8;
use Thrift;
use Thrift::Socket;
use Thrift::BufferedTransport;
use Thrift::BinaryProtocol;
use lib <./HiveConn>;
use ThriftHive;

our @table_names = ('twitter_raw', 'twitter_word_index', 'twitter_word_count', 'twitter_pair_index', 'twitter_pair_count', 'twitter_hash_index', 'twitter_hash_count', 'twitter_tweet');
our %tables = (
		'twitter_raw'        => ['id', 'name', 'usertz', 'followers', 'friends', 'time', 'place', 'hash', 'rtcnt', 'mess', 'yymmdd'],
		'twitter_word_index' => ['id' , 'key_word', 'yymmdd'],
		'twitter_word_count' => ['key_word' , 'cnt', 'yymmdd'],
		'twitter_pair_index' => ['id' , 'markovone' , 'markovtwo', 'yymmdd'],
		'twitter_pair_count' => ['markovone' , 'markovtwo' , 'cnt', 'yymmdd'],
		'twitter_hash_index' => ['id' , 'hash', 'yymmdd'],
		'twitter_hash_count' => ['hash' , 'cnt', 'yymmdd'],
		'twitter_tweet'      => ['id', 'mess', 'hash', 'yymmdd'],
	);
our $tablesRef = \%tables;

sub api1 {
	my ($table_name, $key_word, $markov1, $markov2, $postid, $hash_tag, $newer_than, $date_equals, $older_than, $higher_than, $count_equals, $lower_than, $limit) = @_;
	if($table_name =~ m/^-?\d+$/ ){
		if($table_name >= 0 && $table_name <= 7){
			my $hive_query = "SELECT * FROM $table_names[$table_name]";
			my $work;
			my $querydate = api1_date($newer_than, $older_than, $date_equals, $table_name);
			my $querycount = api1_cnt($higher_than, $lower_than, $count_equals, $table_name);
			if($querycount && $querycount eq "error"){
				return {'error' => 6, 'descript' => 'internal error, table doesnt contain a count field'};
			}
			my $querylimit = api1_limit($limit);
			my $queryoptions = api1_options($querydate, $querycount, $querylimit);
			if($key_word && $key_word =~ /^[a-zA-Z0-9]+$/){
				if("key_word" ~~ $$tablesRef{$table_names[$table_name]}){
					$work = $hive_query . " WHERE $table_names[$table_name].key_word = '$key_word'" . $queryoptions;
				}else{
					return {'error' => 7, 'descript' => 'internal error, table doesnt contain a key_word field'};
				}
			}elsif($markov1 && $markov1 =~ /^[a-zA-Z0-9]+$/ && $markov2 && $markov2 =~ /^[a-zA-Z0-9]+$/){
				if("markovone" ~~ $$tablesRef{$table_names[$table_name]}){
					$work = $hive_query . " WHERE $table_names[$table_name].markovone = '$markov1' AND $table_names[$table_name].markovtwo = '$markov2'" . $queryoptions;
				}else{
					return {'error' => 8, 'descript' => 'internal error, table doesnt contain markov fields'};
				}
			}elsif($postid && $postid =~ /^[a-zA-Z0-9]+$/){
				if("id" ~~ $$tablesRef{$table_names[$table_name]}){
					$work = $hive_query . " WHERE $table_names[$table_name].id = '$postid'" . $queryoptions;	
				}else{
					return {'error' => 9, 'descript' => 'internal error, table doesnt contain a id field'};
				}
			}elsif($hash_tag && $hash_tag =~ /^[a-zA-Z0-9]+$/){
				if("hash" ~~ $$tablesRef{$table_names[$table_name]}){
					$work = $hive_query . " WHERE $table_names[$table_name].hash = '$hash_tag'" . $queryoptions;
				}else{
					return {'error' => 10, 'descript' => 'internal error, table doesnt contain a hash_tag field'};
				}
			}
			$hive_query = $work;
			my %json_hash = (
					'api_version' => 0.1,
					'query' => $hive_query,
					'table' => $table_names[$table_name],
				);
			my $socket = Thrift::Socket->new("h-apps1.t-lab.cs.teu.ac.jp", 10002);
			$socket->setSendTimeout(600 * 1000); # 10min.
			$socket->setRecvTimeout(600 * 1000);
			my $transport = Thrift::BufferedTransport->new($socket);
			my $protocol = Thrift::BinaryProtocol->new($transport);
			my $client = ThriftHiveClient->new($protocol);
			eval {
				$transport->open();
		        $client->execute($hive_query);
		        my $callback = $client->fetchAll();
		        for(my $i = 0; $i < @$callback; $i++){
					my @output = split('\t', $callback->[$i]);
					for(my $j = 0; $j < @output; $j++) {
						$json_hash{results}{$i}{$$tablesRef{$table_names[$table_name]}[$j]} = $output[$j];
					}
					 
				}
				
				$transport->close();
				
			};
			return \%json_hash;


		}else{
			return {'error' => 12, 'descript' => 'table does not excist'};	
		}
	}else{
		return {'error' => 11, 'descript' => 'select tables by number'};	
	}
	return {'error' => 500, 'descript' => 'Internal server error'};
}

#get option
sub api1_options {
	my ($querydate, $querycount, $querylimit) = @_;
	if($querydate && !$querycount && !$querylimit){
		return " AND ${querydate}";
	}elsif(!$querydate && $querycount && !$querylimit){
		return " AND ${querycount}";
	}elsif(!$querydate && !$querycount && $querylimit){
		return " ${querylimit}";
	}elsif($querydate && $querycount && !$querylimit){
		return " AND ${querydate} AND ${querycount}";
	}elsif($querydate && !$querycount && $querylimit){
		return " AND ${querydate} ${querylimit}";
	}elsif(!$querydate && $querycount && $querylimit){
		return " AND ${querycount ${querylimit}";
	}elsif($querydate && $querycount && $querylimit){
		return " AND ${querydate} AND ${querycount} ${querylimit}";
	}else{
		return "";
	}
}
#add a limit for sampling
sub api1_limit {
	my ($limit) = @_;
	my $querylimit;
	if ($limit && $limit  =~ m/^-?\d+$/ && $limit > 0){
		$querylimit = "LIMIT $limit";
	}
	return $querylimit;
}
#specify date
sub api1_date {
	my ($newer_than, $older_than, $date_equals, $table_name) = @_;
	my $querydate;
	if (($newer_than && $newer_than  =~ m/^-?\d+$/ && $newer_than > 0) || ($older_than && $older_than  =~ m/^-?\d+$/ && $older_than > 0) || ($date_equals && $date_equals  =~ m/^-?\d+$/ && $date_equals > 0)){
		if($date_equals){
			$querydate = "$table_names[$table_name].yymmdd = $date_equals";
		}elsif($newer_than && $older_than){
			$querydate = "$table_names[$table_name].yymmdd > $newer_than AND $table_names[$table_name].yymmdd < $older_than";
		}elsif($newer_than && !$older_than){
			$querydate = "$table_names[$table_name].yymmdd > $newer_than";
		}elsif($older_than && !$newer_than){
			$querydate = "$table_names[$table_name].yymmdd < $older_than";
		}
	}
	return $querydate;
}
#specify count
sub api1_cnt {
	my ($higher_than, $lower_than, $count_equals, $table_name) = @_;
	if("cnt" ~~ $$tablesRef{$table_names[$table_name]}){
		my $querycount;
		if (($higher_than && $higher_than  =~ m/^-?\d+$/ && $higher_than > 0) || ($lower_than && $lower_than  =~ m/^-?\d+$/ && $lower_than > 0) || ($count_equals && $count_equals  =~ m/^-?\d+$/ && $count_equals > 0)){
			if($count_equals){
				$querycount = "$table_names[$table_name].cnt = $count_equals";
			}elsif($higher_than && $lower_than){
				$querycount = "$table_names[$table_name].cnt > $higher_than AND $table_names[$table_name].cnt <= $lower_than";
			}elsif($higher_than && !$lower_than){
				$querycount = "$table_names[$table_name].cnt > $higher_than";
			}elsif($lower_than && !$higher_than){
				$querycount = "$table_names[$table_name].cnt < $lower_than";
			}
		}
		return $querycount;
	}else{
		return "";
	}
}
1;