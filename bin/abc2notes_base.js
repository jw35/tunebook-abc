
//set up exports if using Node.js , otherwise skip
if( typeof module !== 'undefined'){
	module.exports = {
	    processABC:processABC
	}
}

function getNote (n_in) {
  var n = n_in;
  n = n.replace(/\/.*/g , "");  
  n = n.replace(/^([A-G])#/ , "^$1");
  n = n.replace(/^([A-G])b/ , "_$1");
 
  // C,=1, C=13, c=25, c'=37, etc
  n = n.replace(/C/g , "+13");
  n = n.replace(/D/g , "+15");
  n = n.replace(/E/g , "+17");
  n = n.replace(/F/g , "+18");
  n = n.replace(/G/g , "+20");
  n = n.replace(/A/g , "+22");
  n = n.replace(/B/g , "+24");
  n = n.replace(/c/g , "+25");
  n = n.replace(/d/g , "+27");
  n = n.replace(/e/g , "+29");
  n = n.replace(/f/g , "+30");
  n = n.replace(/g/g , "+32");
  n = n.replace(/a/g , "+34");
  n = n.replace(/b/g , "+36");
  
  n = n.replace(/\^/ , "+1");	// sharped notes
  n = n.replace(/_/ , "-1");	// flatted notes

  n = n.replace(/=/ , "");	// natural notes
  n = n.replace(/\,/g , "-12");	// one octave below
  n = n.replace(/'/g , "+12");	// one octave above
  
  n = eval(n);

  return n;
}

// Get names of note numbers based on C=1, D=3,...,B=11
function getNoteName(n_in) {
  var n = n_in;
  var ret;
  while (n > 12) { n = n - 12; }
  if (n == 1) { ret = "C"; }
  if (n == 2) { ret = "C#/Db"; }
  if (n == 3) { ret = "D"; }
  if (n == 4) { ret = "D#/Eb"; }
  if (n == 5) { ret = "E"; }
  if (n == 6) { ret = "F"; }
  if (n == 7) { ret = "F#/Gb"; }
  if (n == 8) { ret = "G"; }
  if (n == 9) { ret = "G#/Ab"; }
  if (n == 10) { ret = "A"; }
  if (n == 11) { ret = "A#/Bb"; }
  if (n == 12) { ret = "B"; }
  return ret;
}

//Get relative major of the minor key
function min2maj(key_in) {
  var key = key_in;
  var k;
  //Is this a Dorian key?
  if (/DOR/i.test(key)) {
	 key = key.replace(/DOR/i , "");
	 k = getNote(key);
	 k = k - 2;	// convert to relative major
	 if (k > 24) { k = k - 12; }
  } 
  // Is this a Mixolydian key?
  else if (/mix/i.test(key)) {
	 key = key.replace(/mix/i , "");
	 k = getNote(key);
	 k = k + 5;	// convert to relative major
	 if (k > 24) { k = k - 12; }
  } 
  // Is this a minor key?
  else if (/m/.test(key)) {
	 key = key.replace(/m(in)?(inor)?/ , "");
	 k = getNote(key);
	 k = k + 3;	// convert to relative major
	 if (k > 24) { k = k - 12; }
  } else {
	 k = getNote(key, k);
  }
  return k;
}


// Fixes the abc notes by applying the flats and sharps accordingly

function getTrueNote(note_in, key_in) {
  var note = note_in;
  var key = key_in;

  // First, check if it's a "natural" note. If so, return it
  if ( /\=/.test(note) ) {
	 note = note.replace(/\=/g, "");
	 n = getNote(note);
	 return n;
  }
   
  //Okay, let's look at the key sig
  //Sharps
  n = getNote(note);
  if (/__/.test(note)) { return n; }	// double flats
  if (/\^\^/.test(note)) { return n; }	// double sharps

  k = min2maj(key);
  if (k == 13) { return n; }
  if (n == 6 || n == 18 || n == 30) { n++; } // F -> F#
  if (k == 20) { return n; }
  if (n == 1 || n == 13 || n == 25 || n == 37) { n++; } // C -> C#
  if (k == 15) { return n; }
  if (n == 8 || n == 20 || n == 32) { n++; } // G //> G#
  if (k == 22) { return n; }
  if (n == 3 || n == 15 || n == 27 || n == 39) { n++; } // D -> D#
  if (k == 17) { return n; }
  if (n == 10 || n == 22 || n == 34) { n++; } // A -> A#
  if (k == 24) { return n; }
  if (n == 5 || n == 17 || n == 29) { n++; } // E -> F
  if (k == 19) { return n; }
  if (n == 12 || n == 24 || n == 36) { n++; } // B -> C
  if (k == 14) { return n; }
  
  // Flats
  n = getNote(note);
  k = min2maj(key);
  if (n == 12 || n == 24 || n == 36) { n--; } // B -> Bb
  if (k == 18) { return n; }
  if (n == 5 || n == 17 || n == 29) { n--; } // E -> Eb
  if (k == 23) { return n; }
  if (n == 10 || n == 22 || n == 34) { n--; } // A -> Ab
  if (k == 16) { return n; }
  if (n == 3 || n == 15 || n == 27 || n == 39) { n--; } // D -> Db
  if (k == 21) { return n; }
  if (n == 8 || n == 20 || n == 32) { n--; } // G -> Gb
  if (k == 14) { return n; }
  if (n == 1 || n == 13 || n == 25 || n == 37) { n--; } // C -> Cb
  if (k == 19) { return n; }
  if (n == 6 || n == 18 || n == 30) { n--; } // F -> E
  if (k == 24) { return n; }

  // oops, shouldn't reach this place
  console.error ("abc2notes: There was an error recognising the note \""+note+"\". The notes will probably be wrong.");
  return 0;
}

// harptab layout (C harp)
const tab = new Array();
	tab[0] = "x"; // unknown
	
	tab[1] = "'C"; // C
	tab[2] = "'C#"; // C# / Db
	tab[3] = "'D"; // D
	tab[4] = "'D#"; // E# / Eb
	tab[5] = "'E"; // E
	tab[6] = "'F"; // F
	tab[7] = "'F#"; // F# / Gb
	tab[8] = "'G"; // G
	tab[9] = "'G#"; // G# / Ab
	tab[10] = "'A"; // A
	tab[11] = "'Bb"; // A# / Bb
	tab[12] = "'B"; // B
	
	tab[13] = "C"; // C
	tab[14] = "C#"; // C# / Db
	tab[15] = "D"; // D
	tab[16] = "D#"; // E# / Eb
	tab[17] = "E"; // E
	tab[18] = "F"; // F
	tab[19] = "F#"; // F# / Gb
	tab[20] = "G"; // G
	tab[21] = "G#"; // G# / Ab
	tab[22] = "A"; // A
	tab[23] = "Bb"; // A# / Bb
	tab[24] = "B"; // B
	
	tab[25] = "C'"; // C
	tab[26] = "C#'"; // C# / Db
	tab[27] = "D'"; // D
	tab[28] = "D#'"; // E# / Eb
	tab[29] = "E'"; // E
	tab[30] = "F'"; // F
	tab[31] = "F#'"; // F# / Gb
	tab[32] = "G'"; // G
	tab[33] = "G#'"; // G# / Ab
	tab[34] = "A'"; // A
	tab[35] = "Bb'"; // A# / Bb
	tab[36] = "B'"; // B
	
	tab[37] = "C''"; // C
	tab[38] = "C#''"; // C#
	tab[39] = "D''"; // D

function processABC(input_in, writeFunction, verbose){

	var line_count=0;
	var tune_count=0;
	var abcheaderdone=0;
	var octaveadjust = 0;
	var keysig = "C";
	var transposeharp; 
	var input = input_in.toString();


	var lines = input.split(/\r?\n/);
	for(var i = 0;i < lines.length;i++){
	  var line = lines[i];
	  if (typeof line == 'undefined') {
	 	//continue
	  };
	
	  line_count++;
	  
	  if(/^\s*$/.test(line)){ // whitespace / blank only
	  	 writeFunction(line);
	  } 
	  else if ((/^\w:/.test(line)) || (/^%/.test(line)) || (/\s?\n/.test(line))) {
		 writeFunction(line);
		 
		 if (/^X:\s*(.*)$/.test(line)) {
			// new song, can reset defaults
			abcheaderdone = 0;
			keysig = "C";
			transposeharp = 0;
			octaveadjust = 0;
			var x = line;
			x = x.replace(/^X:\s*(.*)$/ , "$1");
			if (verbose == 1) { console.log( "\nSong number: "+x); }
			tune_count ++;
		 }
		 // print the title
		 if (/^T:\s*(.*)$/.test(line)) {
			var t = line;
			t = t.replace(/^T:\s*(.*)$/ , "$1");
			if (verbose == 1) { console.log( "Title: "+t); }
		 }
		 // this is an ABC field, comment or command, so just print it
		 if (/^K:\s*(.*)$/.test(line)) {
			abcheaderdone = 1;
			
			octaveadjust = 0;
			var k = line;
			k = k.replace(/^K:\s*(.*)$/ , "$1");
			keysig = k;	// note for future: need to adjust for treble+-8
			if (/treble\+8/.test(keysig)) { octaveadjust = 12; }
			if (/treble\-8/.test(keysig)) { octaveadjust = -12; }
			keysig = keysig.replace(/\s?(treble[+-]?\d?|bass\d?|alto\d?|none|perc)/ , "");
			keysig = keysig.replace(/\s?major/ , "");
			keysig = keysig.replace(/\s?maj/ , "");
			keysig = keysig.replace(/%.*/ , ""); // remove comments
			keysig = keysig.replace(/\(.*/ , ""); // remove (... comments etc
			if (verbose == 1) { console.log("Key signature: " + keysig); }
			keysig = keysig.replace(/^([A-G])#/ , "^$1");
			keysig = keysig.replace(/^([A-G])b/ , "_$1");
			// if (verbose == 1) { console.log( "Key signature (decoded): " + keysig); }
			
		 }
	  } 
	  else {
		 // this should be a musical line
		 writeFunction(line);
		 
		 // make a copy - this will be the harp tab line
		 harpline = line;
	
		 harpline = harpline.replace(/\[\w:.*?\]/g , "");
		 
		 // strip to individual notes
		 harpline = harpline.replace(/%.*?$/ , "");	// remove trailing comments
		 harpline = harpline.replace(/\\/g , "");		// remove continuation lines
		 
		 harpline = harpline.replace(/\"(.*?)\"/g , ""); 	// remove all strings
		 harpline = harpline.replace(/[<>\.~]/g , "");	    // remove - < > . ~
		 harpline = harpline.replace(/!.*?!/g , ""); 		// remove !symbols!
		 harpline = harpline.replace(/{.*?}/g , "");		// remove graces {}
		 harpline = harpline.replace(/\(([^\(]*?)\)/g , "$1" ); 		// "de"-slur
		 harpline = harpline.replace(/\[([\^_=]*?[A-Ga-gzx][\,']*).*?\]/g , "$1" );  	// "de"-chord
		 harpline = harpline.replace(/\(\d/g , ""); 		// "de"-tuplet
		 harpline = harpline.replace(/[\|\]:]/g , "");	    // remove barlines
		 harpline = harpline.replace(/\[\d/g , "");		// remove numbered repeats
	
		 harpline = harpline.replace(/([\^_=]*?[A-Ga-gzx][\,']*)\d?\/*?/g , "$1 ");
	
		 harpline = harpline.replace(/\-\s*[\^_=]*?[A-Ga-gzx][\,']*/g , "*"); 	// ties will be skipped
		 harpline = harpline.replace(/\-/g , "");	    // clean up extra ties
	
		 harpline = harpline.replace(/\//g , ""); 		// shorter notes e.g. // or /2 or /4 
		 
		 harpline = harpline.replace(/[zx]\d?/g, "");	// remove rests
	
		 // convert to tab
		 harpline = harpline.replace(/\s+/g , " ");
		 var notes = harpline.split(" ");
		 harpline = "";
		 for (var x = 0; x < notes.length; x++) {
		 	var note = notes[x];
		 	if(/^\s*$/.test(note)){ // whitespace / blank only
			   continue;
	  		}
			else if (note != "*") {
			  var abcnote = note;
			  var note_index = getTrueNote(abcnote, keysig) + octaveadjust + transposeharp;
			  if (note_index < 0) { note_index = 0; }
			  if (note_index > 39) { note_index = 0; }
			  note = tab[note_index];
			  if (typeof note == 'undefined') {
			  	note = "x";
			  }
			  if (note == "x") { console.warn ( "abc2notes: Line "+line_count+": Warning: "+abcnote+" is not recognised"); }
			}
			harpline = harpline + note + " ";
		 }
		 
		 harpline = "w: " + harpline;
		 harpline = harpline.replace(/\s+/g , " ");		// remove extra spaces
		 
		 if (harpline != "w: ") { 
		 	writeFunction(harpline); 
		 }
	  }
	}
	return tune_count;

}
