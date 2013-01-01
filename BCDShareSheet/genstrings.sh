if [ -L $0 ] ; then
    DIR=$(dirname $(readlink -f $0)) ;
else
    DIR=$(dirname $0) ;
fi ;

mkdir -p $DIR/Framework/Supporting\ Files/en.lproj
genstrings -o $DIR/Framework/Supporting\ Files/en.lproj $DIR/Framework/*.m