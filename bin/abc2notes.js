/*
# DESCRIPTION
# abc2notes (based on abc2harp) is a Node JS script that adds the ABC notes to ABC music
# notation in the form of lyrics text. 

# FILENAME
# abc2notes.js

# AUTHOR
# John Keeney
# Gek S. Low


# INSTRUCTIONS
*/
const ver = "0.1";



const help_text = ""+
		"abc2notes.js version "+ver+"							\n"+
		"Usage													\n"+
		"    node abc2notes.js <abcfile.abc | abcfile.txt> [options]	\n"+
		"	 													\n"+
		"    - default output filename is <abcfile>_notes.abc	\n"+
		"														\n"+
		"Options:												\n"+
		"														\n"+
		"-o or -output=<notesfile>								\n"+
		"    - output to <notesfile>.abc						\n"+
		"-writefile=<yes|no>									\n"+
		"    - generates file (overrides -outfile) (default=yes)\n"+
		"-v or -verbose											\n"+
		"    - turns on verbose mode							\n"+
		"";

/*
# NOTES / DISCLAIMERS
# This is very strongly based on abc2harp by Gek S. Low
#
# - This does not cover the full chromatic scale .... 
#
#Original DISCLAIMERS from abc2harp
# - Inline key changes are not supported, but clef changes should be okay
# 
# - This is NOT a parser! I'm just using mostly string substitution to get
# the results I want. I'm too lazy to write a full abc parser.
#
# - I do not claim to handle all possible abc notation scenarios. There are
# features of abc notation which I don't use, so I'm sure there are many
# cases which are broken.
#
# - Finally, use at your own risk! I'm not responsible for any damages, blah
# blah... that may result from the use of this software.

*/
/*
# CHANGE LOG
# Version 0.1: 3 December 2018

*/

const base = require('./abc2notes_base.js');
const fs = require('fs');
const os = require('os');



function processcmdargs(){ 
	if (process.argv.length < 3) {
	  console.error (help_text);
	  throw new Error("Incorrect number of parameters");
	}	
	abcfile = process.argv[2].toString();
	tabfile = abcfile  //+".notes.abc";
	if(/(\.\w\w\w)$/.test(tabfile)){
		tabfile = tabfile = tabfile.replace(/(\.\w\w\w)$/ , "_notes$1");
	}
	else{
		tabfile = tabfile  +"_notes.abc";
	}
	
	
	for (var i = 3; i < process.argv.length; i++) {
	  var arg = process.argv[i].toString();
	  if (/\-o(utput)?\=(.*)$/.test(arg)) {
		 arg = arg.replace(/\-o(utput)?\=(.*)$/ , "$2")
		 tabfile = arg;
	  }
	  else if (/\-writefile\=(.*)$/.test(arg)) {
		 arg = arg.replace(/\-writefile\=(.*)$/ , "$1")
		 writefile = arg;
	  }
	  else if (/\-v(erbose)?$/.test(arg)) {
		 verbose = 1;
	  }
	}
}


function clearFile(){
	if (writefile == "yes") {
		try {
		   fs.closeSync(fs.openSync(tabfile, 'w'));
		} catch (err) {
		  console.error ("Unable to create/clear "+tabfile+" : "+err);
		  throw new Error("Unable to create/clear "+tabfile+" : "+err)
		}
	}
}

function writeoutlinefile (str){
	if (writefile == "yes") {
		try{
			fs.appendFileSync(tabfile, str+os.EOL);
			
		} catch (err) {
	        	console.error(err);
	        	throw err;
	    }
	}
	else{    
		console.log(str);
	}
}

function getInputFile(file){
	try {
	   return fs.readFileSync(file);
	} catch (err) {
	  console.error ("Unable to open "+file+" : "+err);
	  throw new Error("Unable to open "+file+" : "+err)
	}
}


var writefile = "yes";
var verbose = 0;
var abcfile;
var tabfile;

processcmdargs();

var input =  getInputFile(abcfile);
//clear the output
if (writefile == "yes") {
	clearFile();
}

var tunecnt = base.processABC(input, writeoutlinefile, verbose);

if (writefile == "yes") { console.log ("\nabc2notes: Created "+tabfile+". Processed "+tunecnt+" tunes"); }

