DAY11;
 n lines,energy,w,h,x,y,flashes,r
 d ReadLines(.lines,"day11.txt")
 s h=lines(0),w=$l(lines(1))
 f y=1:1:h d
 . f x=1:1:w d
 . . s energy(y,x)=$e(lines(y),x)
 s flashes=0
 f r=1:1:100 s flashes=flashes+$$step(.energy)
 w !,flashes
 f r=101:1 i $$step(.energy)=(w*h) w !,r q
 q
 ;
step(energy);
 n toFlash,flashed,subseqFlashes,x,y,dx,dy,numFlashes
 f y=1:1:h d
 . f x=1:1:w d
 . . s energy(y,x)=energy(y,x)+1
 . . s:energy(y,x)>9 toFlash(y,x)=""
 s x="",y="",numFlashes=0
 f  q:$d(toFlash)=0  d
 . f  s y=$o(toFlash(y)) q:y=""  d
 . . f  s x=$o(toFlash(y,x)) q:x=""  d
 . . . q:$d(flashed(y,x))>0
 . . . s flashed(y,x)="",numFlashes=numFlashes+1
 . . . f dy=-1,0,1 d
 . . . . f dx=-1,0,1 d
 . . . . . q:(dx=0)&(dy=0)  q:x+dx<1  q:x+dx>w  q:y+dy<1  q:y+dy>h
 . . . . . s energy(y+dy,x+dx)=energy(y+dy,x+dx)+1
 . . . . . s:energy(y+dy,x+dx)>9 subseqFlashes(y+dy,x+dx)=""
 . k toFlash
 . m toFlash=subseqFlashes
 . k subseqFlashes
 f  s y=$o(flashed(y)) q:y=""  d
 . f  s x=$o(flashed(y,x)) q:x=""  d
 . . s energy(y,x)=0
 q numFlashes
 ;
ReadLines(lines,file);
 n i,line
 o file:readonly
 u file:exception="g eof"
 f i=1:1 r line s lines(0)=i,lines(i)=line
eof;
 i '$zeo zm +$zs s lines(0)=0
 c file
 q
