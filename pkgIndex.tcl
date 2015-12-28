#===================================================================================
# 版本号：1.0
#   
# 文件名：pkgIndex.tcl
# 
# 文件描述：库索引文件
# 
# 作者：徐俊东(Judo Xu)
#
# 创建时间: 2015.12.18
#
# 修改记录： 
#   
# 版权所有：Ixia
#====================================================================================

if {$::tcl_platform(platform) != "unix"} {
    #如果IxiaCapi库已经加载过，则返回
    if {[lsearch [package names] IxiaBps] != -1} {
        return
    }
}
lappend auto_path C:/Ixia/Libs/Bps/bpsh-win32.vfs/lib
package ifneeded IxiaBps 1.0 [list source [file join $dir IxiaBpsTester.tcl]]

