#!/bin/bash 

# Globals
REPLY_TO="
MAIL_FROM="pdfconvert@thunderkeys.net"
REPLY_TO="no-reply@thunderkeys.net"

# Arguments
SUBJECT="$1"
ATTACHMENT="$2"
ADDRESS="$3"
BLURB_FILE="$4"
ATTACHOLDFILE=`basename "$ATTACHMENT"`

# Strip out quotes and funky UTF-8 characters from filename
ATTACHNEWFILE=`echo "$SUBJECT"|sed -e 's/^Converted: //' -e 's/"/%22/g' -e 's/\xe2\x80\x8b//g'`

MAIL_HEAD=`mktemp`
MAIL_BODY=`mktemp`

rm $MAIL_BODY

if [ -f $BLURB_FILE ]; then
   BLURB="-d $BLURB_FILE"
fi

echo "To: $ADDRESS" >$MAIL_HEAD
echo "From: $FROM" >>$MAIL_HEAD
echo "Reply-To: $REPLY_TO" >>$MAIL_HEAD

mpack $BLURB -s "$SUBJECT" -o $MAIL_BODY "$ATTACHMENT"

if [ ! -z "$ATTACHNEWFILE" ]; then
    # If subject is not empty, replace attachment filename with <subject>.pdf
    perl -pi -e "s~$ATTACHOLDFILE~${ATTACHNEWFILE}.pdf~g" $MAIL_BODY
fi

if [ -s $MAIL_BODY -a -s $MAIL_HEAD ]; then
   cat $MAIL_HEAD $MAIL_BODY | sendmail -i -t
else
   echo "Error assembling message - empty body or header"
   exit 1
fi
rm $MAIL_HEAD $MAIL_BODY
