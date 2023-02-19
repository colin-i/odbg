format elfobj64

#library "libc.so.6"
#importx "printf" printf

datax q#1

entry main()
i3
hex 144,144,144,144
hex 144,144,144,144
hex 144,144,144,144
hex 144,144,144,144
#chars a={66,10,0}
#call printf(#a)
#i3
#call printf(#a)
#i3
#ss a="q"
#call printf(a)
set q 2
return q
