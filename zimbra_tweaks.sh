su - zimbra -c /bin/bash<<'EOF'
source ~/bin/zmshutil
zmsetvars
host=$(zmhostname)

set -x

zmlocalconfig -e ssl_allow_untrusted_certs=true
zmlocalconfig -e mysql_table_cache=250
zmlocalconfig -e mysql_memory_percent=10
zmlocalconfig -e zmmtaconfig_interval=86400
zmlocalconfig -e mailboxd_java_heap_memory_percent=10
zmlocalconfig -e mailboxd_java_heap_size=200
zmlocalconfig -e mailboxd_java_heap_new_size_percent=5
zmlocalconfig -e tomcat_java_heap_memory_percent=40
zmlocalconfig -e mailboxd_thread_stack_size=256k
zmlocalconfig -e mailboxd_java_options="-server -Dhttps.protocols=TLSv1,TLSv1.1,TLSv1.2 -Djdk.tls.client.protocols=TLSv1,TLSv1.1,TLSv1.2 -Djava.awt.headless=true -Dsun.net.inetaddr.ttl=${networkaddress_cache_ttl} -Dorg.apache.jasper.compiler.disablejsr199=true -XX:+UseConcMarkSweepGC -XX:PermSize=64m -XX:MaxPermSize=128m -XX:SoftRefLRUPolicyMSPerMB=1 -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCApplicationStoppedTime -XX:-OmitStackTraceInFastThrow -Xloggc:/opt/zimbra/log/gc.log -XX:-UseGCLogFileRotation -XX:NumberOfGCLogFiles=5 -XX:GCLogFileSize=4096K -Djava.net.preferIPv4Stack=true"
# http://wiki.zimbra.com/wiki/OpenLDAP_Performance_Tuning_8.0
# http://wiki.zimbra.com/wiki/LDAP_Multi_Master_Replication
# http://wiki.zimbra.com/wiki/OpenLDAP_Tuning_Keys_8.0
zmlocalconfig -e ldap_common_thread=4
zmlocalconfig -e ldap_db_cachesize=2
zmlocalconfig -e ldap_db_idlcachesize=6
zmlocalconfig -e ldap_cache_domain_maxsize=1
zmlocalconfig -e ldap_common_loglevel=0
zmlocalconfig -e ldap_common_toolthreads=1
zmlocalconfig -e ldap_db_maxsize=5120000000
zmlocalconfig -e ldap_accesslog_maxsize=5120000000
zmlocalconfig -e ldap_overlay_accesslog_logpurge="01+00:00  00+12:00"
zmlocalconfig -e ldap_overlay_syncprov_checkpoint="50 60"

zmprov -l ms $host -zimbraServiceEnabled amavis
zmprov -l ms $host -zimbraServiceEnabled logger
zmprov -l ms $host -zimbraServiceEnabled antispam
zmprov -l ms $host -zimbraServiceEnabled antivirus
zmprov -l ms $host -zimbraServiceEnabled opendkim
zmprov -l ms $host -zimbraServiceEnabled stats

zmprov -l ms $host zimbraHttpNumThreads 18
zmprov -l ms $host zimbraLmtpNumThreads 5

zmprov mcf zimbraMtaRecipientDelimiter +

# anti spam
zmlocalconfig -e 'postfix_disable_vrfy_command=yes'
zmlocalconfig -e 'postfix_smtpd_delay_reject=yes'
zmlocalconfig -e 'postfix_smtpd_helo_required=yes'
zmlocalconfig -e 'postfix_smtpd_recipient_restrictions=permit_mynetworks,permit_sasl_authenticated,reject_unauth_destinationreject_unauth_pipelining,check_client_accesshash:/etc/postfix/rbl_override,reject_unknown_reverse_client_hostname,reject_invalid_helo_hostname,reject_non_fqdn_hostname,reject_non_fqdn_helo_hostname,reject_non_fqdn_sender,reject_non_fqdn_recipient,reject_unknown_sender_domain,reject_unknown_recipient_domain,reject_invalid_hostname,check_client_accesshash:/etc/postfix/client_checks,reject_rbl_clientzen.spamhaus.org,reject_rbl_clientbl.spamcop.net,reject_rbl_clientb.barracudacentral.org,reject_rbl_clientdnsbl.sorbs.net,check_policy_serviceunix:private/policy,permit'
zmlocalconfig -e 'postfix_smtpd_helo_restrictions=permit_mynetworks,reject_non_fqdn_hostname,reject_invalid_hostname,permit'
EOF
