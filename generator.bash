#! /bin/bash
WORK_DIR=$(cd $(dirname $0); pwd);

if [ ! -d "$WORK_DIR/tmp" ];then
  mkdir $WORK_DIR/tmp
fi

curl -s https://www.ipdeny.com/ipblocks/data/countries/cn.zone -o $WORK_DIR/tmp/all_cn.txt && \
curl -s https://www.ipdeny.com/ipv6/ipaddresses/blocks/cn.zone -o $WORK_DIR/tmp/all_cn_ipv6.txt && \
cat > $WORK_DIR/dist/cn_ip_cidr.rsc << EOF
/log info "Import cn ipv4 cidr list..."
/ip firewall address-list remove [/ip firewall address-list find comment=cn_ip_cidr]
/ip firewall address-list
EOF
cat $WORK_DIR/tmp/all_cn.txt | awk '{ printf(":do {add comment=cn_ip_cidr address=%s list=cn_ip_cidr} on-error={}\n",$0) }' >> $WORK_DIR/dist/cn_ip_cidr.rsc && \
cat >> $WORK_DIR/dist/cn_ip_cidr.rsc << EOF
:if ([:len [/ipv6 dhcp-cl  find where status=bound]] > 0) do={
/log info "Import cn ipv6 cidr list..."
/ipv6 firewall address-list remove [/ipv6 firewall address-list find comment=cn_ipv6]
/ipv6 firewall address-list
EOF
cat $WORK_DIR/tmp/all_cn_ipv6.txt | awk '{ printf(":do {add comment=cn_ipv6 address=%s list=cn_ip_cidr} on-error={}\n",$0) }' >> $WORK_DIR/dist/cn_ip_cidr.rsc && \
echo "}" >> $WORK_DIR/dist/cn_ip_cidr.rsc
