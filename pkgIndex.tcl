#===================================================================================
# �汾�ţ�1.0
#   
# �ļ�����pkgIndex.tcl
# 
# �ļ��������������ļ�
# 
# ���ߣ��쿡��(Judo Xu)
#
# ����ʱ��: 2015.12.18
#
# �޸ļ�¼�� 
#   
# ��Ȩ���У�Ixia
#====================================================================================

if {$::tcl_platform(platform) != "unix"} {
    #���IxiaCapi���Ѿ����ع����򷵻�
    if {[lsearch [package names] IxiaBps] != -1} {
        return
    }
} 
package ifneeded IxiaBps 1.0 [list source [file join $dir IxiaBps.tcl]]
