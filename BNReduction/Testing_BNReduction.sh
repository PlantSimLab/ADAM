#!/bin/bash


program=BuildAndNot/BuildAndNot
if [ -r $program ];
then
  echo " $program Compiled correctly "
else 
  echo " $program did not compiled "
  exit 
fi   

program=NetReductionBoost/NetReduction
if [ -r $program ];
then
  echo " $program Compiled correctly "
else
  echo " $program did not compiled "
  exit
fi

program=ToPolynomial/ToPolynomial
if [ -r $program ];
then
  echo " $program Compiled correctly "
else
  echo " $program did not compiled "
  exit
fi

program=MapFixedPoints/MapFixedPoints
if [ -r $program ];
then
  echo " $program Compiled correctly "
else
  echo " $program did not compiled "
  exit
fi





file=th.dat
if [ -r Examples/$file.fp  ];
then 
  rm Examples/$file.fp
fi 

./BNReduction.sh Examples/$file
echo " Testing Examples/$file .... "
if [ -r Examples/$file.fp  ];
then
  a=` diff CorrectFPoints/"$file".fp Examples/"$file".fp | wc -l`
  if [ "$a" == 0 ] 
  then
     echo "PASSED" 
  else 
     echo "ERROR: Examples/$file.fp different than CorrectFPoints/$file.fp "
  fi
else
  echo "ERROR: Examples/$file.fp is not generated " 
fi 



file=th_one_fixedpoint.dat
if [ -r Examples/$file.fp  ];
then
  rm Examples/$file.fp
fi

./BNReduction.sh Examples/$file
echo " Testing Examples/$file .... "
if [ -r Examples/$file.fp  ];
then
  a=` diff CorrectFPoints/"$file".fp Examples/"$file".fp | wc -l`
  if [ "$a" == 0 ]
  then
     echo "PASSED" 
  else
     echo "ERROR: Examples/$file.fp different than CorrectFPoints/$file.fp "
  fi
else
  echo "ERROR: Examples/$file.fp is not generated " 
fi



file=th_nofixedpoints.dat
if [ -r Examples/$file.fp  ];
then
  rm Examples/$file.fp
fi

./BNReduction.sh Examples/$file
echo " Testing Examples/$file .... "
if [ -r Examples/$file.fp  ];
then
  a=` diff CorrectFPoints/"$file".fp Examples/"$file".fp | wc -l`
  if [ "$a" == 0 ]
  then
     echo "PASSED" 
  else
     echo "ERROR: Examples/$file.fp different than CorrectFPoints/$file.fp "
  fi
else
  echo "ERROR: Examples/$file.fp is not generated " 
fi


file=smallBN.dat
if [ -r Examples/$file.fp  ];
then
  rm Examples/$file.fp
fi

./BNReduction.sh Examples/$file
echo " Testing Examples/$file .... "
if [ -r Examples/$file.fp  ];
then
  a=` diff CorrectFPoints/"$file".fp Examples/"$file".fp | wc -l`
  if [ "$a" == 0 ]
  then
     echo "PASSED" 
  else
     echo "ERROR: Examples/$file.fp different than CorrectFPoints/$file.fp "
  fi
else
  echo "ERROR: Examples/$file.fp is not generated " 
fi

