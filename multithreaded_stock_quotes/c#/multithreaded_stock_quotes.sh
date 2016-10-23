#/bin/bash
#
#   Requires mono :
#   
#       Debian : sudo apt-get install mono-complete
#
#       CentOS :    yum install yum-utils
#                   rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"
#                   yum-config-manager --add-repo http://download.mono-project.com/repo/centos/
#                   yum install mono-devel
#
EXECUTABLE="./multithreaded_stock_quotes.exe"
SYMBOL_FILE="./symbols.txt"
cd build/linux
make
cd ../..
chmod +x $EXECUTABLE
mono $EXECUTABLE $SYMBOL_FILE