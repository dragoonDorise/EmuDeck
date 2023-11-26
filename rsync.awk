{
   if (index($0, "to-check=") > 0)
   {
	split($0, pieces, "to-check=")
	split(pieces[2], term, ")");
	split(term[1], division, "/");
	print (1-(division[1]/division[2]))*100"%"
   }
   else
   {
	print "#"$0;
   }
   fflush();
}