Note for 1.8.3_beta1_v5.txt:
"Fix" a bug  previous made.
Slightly faster when scan.
Build files update.
Other changes by contributors.

tianwei 20120102
-----------------------------------------------------------


Note for 1.8.3_beta1_v4_repack.txt:
Add compatible project build directory by XhmikosR
Others are not changed.

tianwei 20120101
-----------------------------------------------------------


Note for 1.8.3_beta1_v4.txt:
Figure out why v1-v4 diffs in compilers.:)
So in this package, all .exe are compiled with Visual Studio 2010

182to183.exe
regshot.exe
regshot_x64.exe

Fix small bugs and a little change.
ps: v1 and v2 are bad. v3 is good. v4 is unknow ;)

tianwei 20111230
-----------------------------------------------------------


Note for 1.8.3_beta1_v3.txt:
It turns out that v2 using MS VS 6 (a old compiler) may be wrong.
So in this package,I use XhmikosR's build (with WDK), It is small and clean!
And fix a crash bug in compare.

regshot.exe
regshot_x64.exe

but the 182to183.exe still remain in vs6 build until newer one comes.
(If you got to run regshot on old machine,please use 1.8.2 until new build)

tianwei 20111229

-------------------------------------------------------------
Note for 1.8.3_beta1_v2.txt
After I release the 1.8.3_beta1 at 20111225
I found some problem in my visual studio 2010 compiler in VM,
so I release the 1.8.3_beta1 v2 package with two files re-compiled with old MS VS 6 

182to183.exe
regshot.exe

so the regshot_x64.exe may have trouble when running.

tianwei 20111227