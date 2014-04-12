newPackage(  "GSTOPDS" ,
        Version => "0.2",
        Headline => "convert ginsim to pds",
--Author	Alan Veliz-Cuba
        Date => "May 9, 2010")

export{fromGStoLM, fromLMtoTT, fromTTtoPDS, Rring,
fromGStoTT, fromLMtoPDS, fromGStoPDS,
fromPDStoFN, fromFNtoTT, getListOfGenes}

--the following functions read the features of the XML file (ginsim file)
attri:=(s,a) -> ( 
  r:=#s-1;
  t:=#a;
  Na:="";
  u:=0;
  for i to r do (
    if concatenate s_(i,t+2)==" "|a|"=" then (
      u = i+t+3;
      for j from u to r do (
        if s_j!="\"" then 
          Na=Na|s_j 
        else 
          break
      );
      break
    )
  );
  Na
);

attris:=(s,La)->(
  r:=#La;
  NLa:={};
  for i to r-1 do (NLa=append(NLa,attri(s,La_i)));
  NLa
);

demI:=(SS,d)->(
  r:=#SS-1;
  t:=#d;
  Nd:="<"|d;
  u:=0;
  for i to r do (if SS_(i,t+2)=="<"|d|" " or SS_(i,t+2)=="<"|d|">" then 
  (u=i+t+1;
  for ii from u to r do (if SS_ii!=">" then Nd=Nd|SS_ii else break);
  Nd=Nd|">";
  break));
  Nd
);

demsI:=(SS,d,k)->(
  r:=#SS-1;
  t:=#d;
  ND:={};
  u:=0;
  for j to k-1 do (Nd:="<"|d;
  for i from u to r do (if SS_(i,t+2)=="<"|d|" " or SS_(i,t+2)=="<"|d|">"then 
  (u=i+t+1;for ii from u to r do (if SS_ii!=">" then Nd=Nd|SS_ii else (u=ii+1; break));ND=append(ND,Nd|">");break));
  );ND
);

demsIAll:=(SS,d)->(
  r:=#SS-1;
  t:=#d;
  ND:={};
  u:=0;
  while u<r do (
    Nd := "<"|d;
    for i from u to r do (
      if i==r then (
        u=r;
        break
      );
      if SS_(i,t+2)=="<"|d|" " or SS_(i,t+2)=="<"|d|">" then (
        u=i+t+1;
        for ii from u to r do (
          if SS_ii!=">" then 
            Nd=Nd|SS_ii 
          else (
            u=ii+1;
            break
          )
        );
        ND=append(ND,Nd|">");
        break
      )
    );
  );
  ND
);

demAll:=(SS,d)->(
  r:=#SS-1;t:=#d;Nd:="<"|d;u:=0;
  for i to r do (if SS_(i,t+2)=="<"|d|" " or SS_(i,t+2)=="<"|d|">" then 
  (u=i+t+1;for ii from u to r do (if SS_(ii,t+3)!="</"|d|">" then Nd=Nd|SS_ii else break);Nd=Nd|"</"|d|">";break));
  Nd
);

demsAll:=(SS,d,k)->(
  r:=#SS-1;t:=#d;ND:={};u:=0;for j to k-1 do (Nd:="<"|d;
  for i from u to r do (if SS_(i,t+2)=="<"|d|" " or SS_(i,t+2)=="<"|d|">"then 
  (u=i+t+1;for ii from u to r do (if SS_(ii,t+3)!="</"|d|">" then Nd=Nd|SS_ii else (u=ii+1;break));ND=append(ND,Nd|"</"|d|">");break));
  );ND
);


demsattri:=(SS,d,a,A)->(
  r:=#SS-1;t:=#d;Nd:="<"|d;u:=0;
  for i to r do (if SS_(i,t+2)=="<"|d|" " then 
  (u=i+t+1;Nd="<"|d;for ii from u to r do (if SS_ii!=">" then Nd=Nd|SS_ii else (u=ii+1;break));Nd=Nd|">";if attri(Nd,a)==A then (for ii from u to r do (if SS_(ii,t+3)!="</"|d|">" then Nd=Nd|SS_ii else break) ;return Nd|"</"|d|">") else (i=u+#Nd;Nd:="<"|d)));
  ""
);

--converts a ginsim file to a logical model
fromGStoLM=method()
fromGStoLM(String) := gfile -> (
  GG := get gfile;
  g := demI( GG, "graph");
  idGS := attri(g,"id");
  classGS := attri(g,"class");
  nodesGS := separate(" ",attri(g,"nodeorder"));
  n := #nodesGS;
  NMB := apply(demsI( GG,"node",n), x -> attris( x, {"id","name","basevalue","maxvalue"}));
  P := apply((transpose NMB)_0,x->position(nodesGS,xx->xx==x));
  NMB = transpose drop(transpose sort transpose prepend(P,transpose NMB),1);
  M := (transpose NMB)_3;
  B := (transpose NMB)_2;
  NAMES := (transpose NMB)_0;
  --
  EdgesGS := apply(demsIAll(GG,"edge"),x->attris(x,{"from","to","minvalue","maxvalue","id","sign"}));
  --
  E:={};
  for i to #EdgesGS-1 do (e:=EdgesGS_i;
  if e_3=="" then e=join(e_{0,1,2},{M_(position(NAMES,x->x==e_0)),e_4_(#(e_0)+#(e_1)+2,#(e_4)-#(e_0)-#(e_1)-2)}) else e=append(e_{0,1,2,3},e_4_(#(e_0)+#(e_1)+2,#(e_4)-#(e_0)-#(e_1)-2));
  E=append(E,e));
  --
  EE:=for i to n-1 list new MutableList;
  for i to #E-1 do (e:=E_i;
  edge:=e_0|"_"|e_1|"_"|toString(e_4);
  k:=position(nodesGS,x->x==e_1);
  EE#k#(#EE#k)={e_0,e_2,e_3,edge});
  --
  EEE:=for i to n-1 list new MutableList;
  for i to n-1 do (EEi:=EE#i;
  aa:=demsattri(GG,"node","id",nodesGS_i);
  EEE#i#0={{},attri(aa,"basevalue")};
  dd:=demsIAll(aa,"parameter");
  if #dd>0 then (ee:=for j to #dd-1 list attris(dd_j,{"idActiveInteractions","val"});
  for ii to #ee-1 do ( e:=separate(" ",(ee_ii)_0);
  e=for j to #e-1 list (k:=position(toList EEi,x->x_3==e_j);
  EEi#k_{0,1,2});
  EEE#i#(#EEE#i)={e,(ee_ii)_1}))   );
  EEE=EEE/toList;
  --
  EE=EE/toList;
  EE=apply(EE,x->apply(x,y->(y_0,value y_1,value y_2)));
  E=apply(EE,x->(toList set for i to #x-1 list (x#i)_0));
  --
  M=M/value;
  --
  EEE=apply(EEE,K->for i to #K-1 list ((e,v):=toSequence K_i;
  {for j to #e-1 list (x:=e_j;
  (x_0,value x_1,value x_2)),value v}));
  --
  EEEE:={};for i to n-1 do (Ei:=E_i;pp:=for j to #Ei-1 list position(nodesGS,x->x==Ei_j); pp=sort(pp);EEEE=append(EEEE,for j to #pp-1 list nodesGS_(pp_j)));
  E=EEEE;
  --
  signs:=apply(EdgesGS,x->(s:="unknown";if x_5=="positive" then s=1;if x_5=="negative" then s=-1;return append(x_{0,1},s)));
  signs=toList set signs;
  Signs:=for i to n-1 list new MutableList; for i to #signs-1 do (e:=signs_i; k:=position(nodesGS,x->x==e_1);Signs#k#(#Signs#k)=e_{0,2});
  Signs=Signs/toList;
  signs=for i to n-1 list (eS:=Signs_i;ee:=E_i;SS:=for j to #ee-1 list ( 
  p:=select(eS,x->x_0==ee_j);s:="unknown";ss:=(transpose p)_1;if #ss==1 then  
   s=ss_0;if isSubset({1,-1},ss) then s="none";s
  );SS );
  --
  return ({M,nodesGS},EE,EEE,{E,signs})
);

Active:=(d,L)->(n:=#d;S:={};for i to n-1 do (l:=L_i;for j to #l-1 do (if l_j_1<= d_i and d_i<=l_j_2 then S=append(S,l_j)));return S);

toD=method();
toD(ZZ,List):=(d,M)->(
  L:={};n:=#M-2;if d==0 then L=(for i to n+1 list 0) else (m:=d;for i to n+1 do (pro:=product M_{0..n-i};q:=m//pro;m=m-q*pro;L=append(L,q))); L );
  toD(ZZ,ZZ,ZZ):=(d,p,N)->(L:={};pn:=1;n:=0;if d==0 then L={0} else (while pn<=d do (pn=pn*p;n=n+1);n=n-1; m:=d;for i to n do (w:=p^(n-i);q:=m//w;m=m-q*w;L=append(L,q))); for i to N-(n+2) do L=prepend(0,L); L 
);

TT:=(I,EEI,KI,M)->(H:=new MutableHashTable;if #I==0 then (if #KI==0 then H#null=0 else H#null=KI_0_1;return H);n:=#I;L:=for i to n-1 list new MutableList;for i to #EEI-1 do (e:=EEI_i;p:=position(I,x->x==e_0);L#p#(#L#p)=e);L=L/toList;MM:=reverse M + for i to n-1 list 1;mm:=product MM;for i to mm-1 do (d:=toD(i,MM);S:=Active(d,L);v:=0;for j to #KI-1 do (kj:=KI_j;if S==kj_0 then v=kj_1);H#d=v);  H );

fromD=method()
fromD(VisibleList):=(L)->(n:=#L;d:=L_0;for i from 1 to n-1 do d=d*2+L_i;d);
fromD(VisibleList,ZZ):=(L,p)->(n:=#L;d:=L_0;for i from 1 to n-1 do d=d*p+L_i;d);
fromD(VisibleList,List):=(L,M)->(n:=#L;m:=#M;d:=L_0;for i from 1 to n-1 do d=d*M_i+L_i;d);

--converts a logical model to a truth table
fromLMtoTT=method()
fromLMtoTT(List,List,List,List):=(nodesGS,M,EE,EEE)->(
  n:=#M;E:=apply(toList EE,x->(toList set for i to #x-1 list (x#i)_0));
  EEEE:={};
  for i to n-1 do (Ei:=E_i;
  pp:=for j to #Ei-1 list position(nodesGS,x->x==Ei_j);
  pp=sort(pp);
  EEEE=append(EEEE,for j to #pp-1 list nodesGS_(pp_j)));
  E=EEEE;
  --
  EEE=for i to n-1 list (e:=EEE_i;
  EI:=E_i;
  for j to #e-1 list (f:=e_j_0;
  po:=apply(f,x->position(E_i,y->y==x_0));
  f=f_(apply(sort po,x->position(po,y->x==y))) ;
  {f,e_j_1} ));
  --
  FF:=new MutableHashTable;
  for i to n-1 do FF#i=TT(E_i,EE_i,EEE_i,apply(E_i,x->(p:=position(nodesGS,y->y==x);
  M_p)));
  --
  E=apply(E,I->apply(I,v->1+position(nodesGS,y->y==v)));
  return (FF,M,E)
);


-- this returns a list of all the variables, so that one knows which gene xi is
getListOfGenes = method()
getListOfGenes String := List => gfile -> (
  (MnodesGS, EE, EEE, Esigns) := fromGStoLM( gfile );
  print "Variables: ";
  variables := last MnodesGS;
  scan( (1..#variables), i -> print ("x" | i | " = " | variables_(i-1)) );
  variables
)

-- converts a GinSim File into a truth table
fromGStoTT = method()
fromGStoTT( String ) := gfile -> (
  (MnodesGS, EE, EEE, Esigns) := fromGStoLM( gfile );
  print "Variables: ";
  variables := last MnodesGS;
  scan( (1..#variables), i -> print ("x" | i | " = " | variables_(i-1)) );
  fromLMtoTT( MnodesGS_1, MnodesGS_0, EE, EEE )
);

--converts a truth table to a polynomial dynamical system
fromTTtoPDS = method(Options => { Rring => null})
fromTTtoPDS(HashTable,List,List) := opts -> (FF,M,I)->(
  p:= 1+max M;
  while isPrime p  == false do (p = p+1);
  n:= #M;
  R:= 0;
  --
  if opts.Rring =!= null then 
    R = opts.Rring 
  else  (
    X:= for i from 1 to n list ("x"|i);
    --X:= for i from 1 to n list ("local x"|i);
    R = ZZ/p[X/value]; --R = ZZ/p[X/value,MonomialOrder  => Lex];
    XPX:= gens R;
    XPX = apply(XPX,x->x^p-x);
    R = R/ideal XPX   
  );
  X = gens R;
  --
  POLY:= for i to n-1 list (     
    m:= #I_i;
    ind:= I_i-for j to m-1 list 1;
    XI:= X_ind;
    MI:= M_ind;
    F:= FF#i;
    if #F == 1  then     
      F#null    
    else ( 
      term:= d -> ( 
        v := toD(d,p,m);
        fv:= F#(for i to m-1 list (min(v_i,MI_i)));
        P:= product(for i to m-1 list (1-(XI_i-v_i)^(p-1)));
        fv*P
      );
      sum(0..p^m-1,d->term(d)) 
    )     
  );
  --matrix(R, {POLY} )
  (POLY,R)
);

fromLMtoPDS=method(Options =>{Rring => null})
fromLMtoPDS(List,List,List,List):=opts->(nodesGS,M,EE,EEE)->(
return fromTTtoPDS(fromLMtoTT(nodesGS,M,EE,EEE),Rring=>opts.Rring));

-- generates a PDS from a GinSim file
-- takes a ring as optional argument
fromGStoPDS = method( Options => {Rring => null} )
fromGStoPDS( String ) := opts -> gfile -> (
  print ("loading "|gfile|" ...");
  fromTTtoPDS fromGStoTT gfile 
)

fromFNtoTT=method()
fromFNtoTT(Function,ZZ,ZZ):=(f,p,n)->(H:=new MutableHashTable;
for i to p^n-1 do (v:=toD(i,p,n);H#v=f(v));H );

fromPDStoFN=method()
fromPDStoFN(RingElement,Ring):=(PP,R)->(
  P:=PP;
  XX:=gens R;
  n:=#XX;
  p:=char R;
  W:=R[vars(53..52+n)];
  XW:=gens W;
  P=value(toString P);
  S:=for i to n-1 list (XX_i=>XW_i);
  S=toString sub(P_W,S);
  SS:=toString toSequence for i from 1 to n list ("x"|i);
  return value (SS|"->("|S|")%"|p)  
);

--
fromPDStoFN(List,Ring):=(LLP,R)->(
  LP:=LLP;
  m:=#LP;
  XX:=gens R;
  n:=#XX;
  p:=char R;
  W:=R[vars(53..52+n)];
  XW:=gens W;
  LP=apply(LP,P->value (toString P));
  S:=for i to n-1 list (XX_i=>XW_i);
  S=toSequence apply(LP,P->toString sub(P,S));
  S=toString apply(S,s->"("|s|")%"|p);
  SS:=toString toSequence for i from 1 to n list ("x"|i);
  return value (SS|"->"|S)  
);

end

installPackage "GSTOPDS"
