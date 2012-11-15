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
	var markov2 = $('#markovtwo').val();
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
	}else if(tableToSearch == 'twitter_word_count'){
		query += 'table_name=2';
		if(keyword){
			query += ';key_word=';
			query += keyword;	
		}
		if(countform && countnr){
			console.log(countform);
			if(countform == 'counteq'){
				query += ';count_equals=';
			}else if(countform == 'counthigher'){
				query += ';higher_than=';
			}else if(countform == 'countlower'){
				query += ';lower_than=';
			}
			query += countnr;
		}
	}else if(tableToSearch == 'twitter_pair_index'){
		query += 'table_name=3';
		if(markov1 && markov2){
			query += ';markov1=';
			query += markov1;
			query += ';markov2=';
			query += markov2;
		}

		if(entryid){
			query += ';postid=';
			query += entryid;
		}
	}else if(tableToSearch == 'twitter_pair_count'){
		query += 'table_name=4';
		if(markov1 && markov2){
			query += ';markov1=';
			query += markov1;
			query += ';markov2=';
			query += markov2;
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
			query += ';hash_tag=';
			query += hashtag;
		}
		if(entryid){
			query += ';postid=';
			query += entryid;
		}
	}else if(tableToSearch == 'twitter_hash_count'){
		query += 'table_name=6';
		if(hashtag){
			query += ';hash_tag=';
			query += hashtag;
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
