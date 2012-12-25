#!/usr/bin/perl

#Copyright (c) 2012 Johan Gustavsson <johan@life-hack.org>
#
#Hive-api is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#Hive-api is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with Hive-api.  If not, see <http://www.gnu.org/licenses/>.


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

our @table_names_api = ('twitter_raw', 'twitter_tweet', 'twitter_word_index', 'twitter_pattern_index', 'twitter_hash_index');
our %tables_api = (
		'twitter_raw'           => ['id', 'name', 'usertz', 'followers', 'friends', 'time', 'place', 'hash', 'rtcnt', 'mess', 'yymmdd'],
		'twitter_word_index'    => ['key_word', 'adj', 'adv', 'verb', 'noun', 'cnt', 'id', 'rtcnt','yymmdd'],
		'twitter_pattern_index' => ['first' , 'second' , 'third', 'cnt', 'id', 'rtcnt', 'yymmdd'],
		'twitter_hash_index'    => ['hash',  'cnt', 'id', 'rtcnt', 'yymmdd'],
		'twitter_tweet'         => ['id', 'mess', 'hash', 'yymmdd'],
	);
our $tableRef_api = \%tables_api;

sub api1 {
	my ($table_name, $key_word, $postid, $newer_than, $date_equals, $older_than, $higher_than, $count_equals, $lower_than, $limit, $VERSION, $ADDR, $PORT) = @_;
	if($table_name =~ m/^-?\d+$/ ){
		if($table_name >= 0 && $table_name <= 7){
			my $hive_query = "SELECT * FROM $table_names_api[$table_name]";
			my $work;
			my $querydate = api1_date($newer_than, $older_than, $date_equals, $table_name);
			my $querycount = api1_cnt($higher_than, $lower_than, $count_equals, $table_name);
			if($querycount && $querycount eq "error"){
				return {'error' => 6, 'descript' => 'internal error, table doesnt contain a count field'};
			}
			my $querylimit = api1_limit($limit);
			my $queryoptions = api1_options($querydate, $querycount, $querylimit);
			if($table_name == 2 && $key_word && $key_word =~ /^[a-zA-Z0-9]+$/){
				if("key_word" ~~ $$tableRef_api{$table_names_api[$table_name]}){
					$work = $hive_query . " WHERE $table_names_api[$table_name].key_word = '$key_word'" . $queryoptions;
				}else{
					return {'error' => 7, 'descript' => 'internal error, table doesnt contain a key_word field'};
				}
			}elsif($table_name == 3 && $key_word && $key_word =~ /^[a-zA-Z0-9]+$/ && $key_word && $key_word =~ /^[a-zA-Z0-9]+$/){
				if("second" ~~ $$tableRef_api{$table_names_api[$table_name]}){
					$work = $hive_query . " WHERE $table_names_api[$table_name].second = '$key_word'" . $queryoptions;
				}else{
					return {'error' => 8, 'descript' => 'internal error, table doesnt contain markov fields'};
				}
			}elsif($postid && $postid =~ /^[a-zA-Z0-9]+$/){
				if("id" ~~ $$tableRef_api{$table_names_api[$table_name]}){
					$work = $hive_query . " WHERE $table_names_api[$table_name].id = '$postid'" . $queryoptions;	
				}else{
					return {'error' => 9, 'descript' => 'internal error, table doesnt contain a id field'};
				}
			}elsif($table_name == 4 && $key_word && $key_word =~ /^[a-zA-Z0-9]+$/){
				if("hash" ~~ $$tableRef_api{$table_names_api[$table_name]}){
					$work = $hive_query . " WHERE $table_names_api[$table_name].hash = '$key_word'" . $queryoptions;
				}else{
					return {'error' => 10, 'descript' => 'internal error, table doesnt contain a key_word field'};
				}
			}
			$hive_query = $work;
			my %json_hash = (
					'api_version' => $VERSION,
					'query' => $hive_query,
					'table' => $table_names_api[$table_name],
				);
			my $socket = Thrift::Socket->new($ADDR, $PORT);
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
						$json_hash{results}{$i}{$$tableRef_api{$table_names_api[$table_name]}[$j]} = $output[$j];
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

sub api2 {
	my ($table_name, $key_word, $postid, $newer_than, $date_equals, $older_than, $higher_than, $count_equals, $lower_than, $limit) = @_;
	if($table_name =~ m/^-?\d+$/ ){
		if($table_name >= 0 && $table_name <= 4){


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
			$querydate = "$table_names_api[$table_name].yymmdd = $date_equals";
		}elsif($newer_than && $older_than){
			$querydate = "$table_names_api[$table_name].yymmdd > $newer_than AND $table_names_api[$table_name].yymmdd < $older_than";
		}elsif($newer_than && !$older_than){
			$querydate = "$table_names_api[$table_name].yymmdd > $newer_than";
		}elsif($older_than && !$newer_than){
			$querydate = "$table_names_api[$table_name].yymmdd < $older_than";
		}
	}
	return $querydate;
}
#specify count
sub api1_cnt {
	my ($higher_than, $lower_than, $count_equals, $table_name) = @_;
	if("cnt" ~~ $$tableRef_api{$table_names_api[$table_name]}){
		my $querycount;
		if (($higher_than && $higher_than  =~ m/^-?\d+$/ && $higher_than > 0) || ($lower_than && $lower_than  =~ m/^-?\d+$/ && $lower_than > 0) || ($count_equals && $count_equals  =~ m/^-?\d+$/ && $count_equals > 0)){
			if($count_equals){
				$querycount = "$table_names_api[$table_name].cnt = $count_equals";
			}elsif($higher_than && $lower_than){
				$querycount = "$table_names_api[$table_name].cnt > $higher_than AND $table_names_api[$table_name].cnt <= $lower_than";
			}elsif($higher_than && !$lower_than){
				$querycount = "$table_names_api[$table_name].cnt > $higher_than";
			}elsif($lower_than && !$higher_than){
				$querycount = "$table_names_api[$table_name].cnt < $lower_than";
			}
		}
		return $querycount;
	}else{
		return "";
	}
}
1;