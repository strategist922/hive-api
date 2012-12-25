/*
Copyright (c) 2012 Johan Gustavsson <johan@life-hack.org>

Hive-api is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Hive-api is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Hive-api.  If not, see <http://www.gnu.org/licenses/>.
*/

$(document).ready(function() {
	$('#dispword, #dispmarkov, #dispid, #disphash, #dispdate, #dispcount, #displimit').hide();

	$('#formselect').change(function() {
		$('#formapi' + $(this).find('option:selected').attr('id')).show();
		$('#dispword, #dispmarkov, #dispid, #disphash, #dispdate, #dispcount, #displimit').hide();
	});
	$('#dateformat').change(function() {
		var dform = $(this).find('option:selected').attr('id');
		if(dform == 'datespan'){
			$('#dispdate1').show();
		}else{
			$('#dispdate1').hide();
		};
		
	});
	$('#api1tableselect').change(function() {
		var table = $(this).find('option:selected').attr('id');
		if(table == 'tabl0'){
			$('#dispid, #displimit, #dispdate, #dispword, #dispmarkov, #disphash, #dispcount, #dispdate1').hide();
			$('#dispid, #displimit, #dispdate').show();
		}else if(table == 'tabl1'){
			$('#dispid, #displimit, #dispdate, #dispword, #dispdate1, #dispmarkov, #disphash, #dispcount').hide();
			$('#dispid, #displimit, #dispdate, #dispword').show();
		}else if(table == 'tabl2'){
			$('#dispid, #displimit, #dispdate, #dispword, #dispmarkov, #dispdate1, #disphash, #dispcount').hide();
			$('#displimit, #dispdate, #dispcount, #dispword').show();
		}else if(table == 'tabl3'){
			$('#dispid, #displimit, #dispdate, #dispword, #dispmarkov, #disphash, #dispdate1, #dispcount').hide();
			$('#dispid, #displimit, #dispdate, #dispmarkov').show();
		}else if(table == 'tabl4'){
			$('#dispid, #displimit, #dispdate, #dispword, #dispmarkov, #disphash, #dispcount, #dispdate1').hide();
			$('#displimit, #dispdate, #dispcount, #dispmarkov').show();
		}else if(table == 'tabl5'){
			$('#dispid, #displimit, #dispdate, #dispword, #dispmarkov, #dispdate1, #disphash, #dispcount').hide();
			$('#dispid, #displimit, #dispdate, #disphash').show();
		}else if(table == 'tabl6'){
			$('#dispid, #displimit, #dispdate, #dispword, #dispmarkov, #disphash, #dispdate1, #dispcount').hide();
			$('#displimit, #dispdate, #dispcount, #disphash').show();
		}else if(table == 'tabl7'){
			$('#dispid, #displimit, #dispdate, #dispword, #dispmarkov, #disphash, #dispcount, #dispdate1').hide();
			$('#dispid, #displimit, #dispdate').show();
		}
	});
});
function DoSearch1(){
	var tableToSearch = $('#api1tableselect').val();
	var keyword = $('#key_word').val();
	var markov1 = $('#markovone').val();
	var entryid = $('#entryid').val();
	var hashtag = $('#hashtag').val();
	var dateformat = $('#dateformat').val();
	var datefrom = $('#datefrom').val();
	var dateto = $('#dateto').val();
	var countform = $('#countformat').val();
	var countnr = $('#countnr').val();
	var limit = $('#limitamount').val();
	var query = "/api1-json?";
	var html = "<h1>Processing...</h1>";
	$('#searchoutput').html(html);
	if(tableToSearch == 'twitter_raw'){
		query += 'table_name=0';
		if(entryid){
			query += ';postid=';
			query += entryid;
		}
	}else if(tableToSearch == 'twitter_word_index'){
		query += 'table_name=1';
		if(keyword){
			query += ';key_word=';
			query += keyword;	
		}
		if(entryid){
			query += ';postid=';
			query += entryid;
		}
		if(countformat && countnr){
			if(countformat == 'counteq'){
				query += ';count_equals=';
			}else if(countformat == 'counthigher'){
				query += ';higher_than=';
			}else if(countformat == 'countlower'){
				query += ';lower_than=';
			}
			query += countnr;
		}
	}else if(tableToSearch == 'twitter_pattern_index'){
		query += 'table_name=3';
		if(markov1){
			query += ';key_word1=';
			query += markov1;
		}

		if(entryid){
			query += ';postid=';
			query += entryid;
		}
		if(countformat && countnr){
			if(countformat == 'counteq'){
				query += ';count_equals=';
			}else if(countformat == 'counthigher'){
				query += ';higher_than=';
			}else if(countformat == 'countlower'){
				query += ';lower_than=';
			}
			query += countnr;
		}
	}else if(tableToSearch == 'twitter_hash_index'){
		query += 'table_name=5';
		if(hashtag){
			query += ';key_word=';
			query += hashtag;
		}
		if(entryid){
			query += ';postid=';
			query += entryid;
		}
		if(countformat && countnr){
			if(countformat == 'counteq'){
				query += ';count_equals=';
			}else if(countformat == 'counthigher'){
				query += ';higher_than=';
			}else if(countformat == 'countlower'){
				query += ';lower_than=';
			}
			query += countnr;
		}
	}else if(tableToSearch == 'twitter_tweet'){
		query += 'table_name=7';
		if(entryid){
			query += ';postid=';
			query += entryid;
		}
	}
	if(dateformat && datefrom){
		if(datefrom == 'datespan' && dateto){
			query += ';older_than=';
			query += datefrom;
			query += ';newer_than=';
			query += dateto;
		}else{
			if(dateformat == 'dateeq'){
				query += ';date_equals=';
				query += datefrom;
			}else if(dateformat == 'datenewer'){
				query += ';newer_than=';
				query += datefrom;
			}else if(dateformat == 'dateolder'){
				query += ';older_than=';
				query += datefrom;
			}
		}

	}
	if(limit){
		query += ';limit=';
		query += limit;
	}
	console.log(query);
	$.getJSON(query,function(data){
		console.log(data);
		if(data.error){
			html = '<h1>ERROR ';
			html += data.error;
			html += '</h1><br><h2>';
			html += data.descript;
			html += '</h2>';
			$('#results').html("unko");
		}else{
			html = "<h2>Options:</h2><br><pre>"
			html += 'APIV. : ';
			html += data.api_version;
			html += '<br>QUERY : ';
			html += data.query;
			html += '<br>TABLE : ';
			html += data.table;
			html += "</pre><br><h2>RESULTS:</h2><br><table class='table table-striped'>\n";
			var top = 0;
			for(var key in data.results){
				var obj = data.results[key];
				html += "<tr>\n";
				if(top == 0){
					for(var prop in obj){
						html += "<td>" + prop + "</td>\n";
					}
					top = 1;
					html += "</tr><tr>\n";
				}
				for(var prop in obj){
					html += "<td>" + obj[prop] + "</td>\n";
				}
				html += "</tr>\n";
			}
			html += "</table>\n";
		}
		$('#searchoutput').html(html);
		return false;
	});
}
