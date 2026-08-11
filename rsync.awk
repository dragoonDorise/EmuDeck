 {
	if (match($0, /to-ch(k|eck)=[0-9]+\/[0-9]+/)) {
			split(substr($0, RSTART, RLENGTH), a, "=")
			split(a[2], d, "/")
			if (d[2] > 0) print (1 - d[1]/d[2]) * 100 "%"
	} else {
			print "#" $0
	}
	fflush()
  }