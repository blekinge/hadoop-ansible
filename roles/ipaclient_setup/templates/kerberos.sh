{{ ansible_managed | comment() }}

export KRB5CCNAME=FILE:/tmp/krb5cc_$UID
