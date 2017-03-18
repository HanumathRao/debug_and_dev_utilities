This is a multithreaded stock quotes querying code. It has been implemented in Python (2.7) and C# ( .Net for Windows and Mono for Linux ).

**How it works :** They load RIC symbols from a text file and gets the quotes by using Yahoo Finance API. They fire one thread per symbol. Regarding Yahoo Finance api , see section below.

**Example output :**

			----------------------------------------------------------------------------
			Entire execution took 2548 milliseconds

			Number of threads fired : 8
			----------------------------------------------------------------------------

			0 : AAPL 110.56 , in 1128 milliseconds
			1 : INTC 36.30 , in 1343 milliseconds
			2 : MSFT 46.45 , in 1513 milliseconds
			3 : GOOGL 530.70 , in 910 milliseconds
			4 : QCOM 74.40 , in 1321 milliseconds
			5 : QQQ 103.35 , in 1119 milliseconds
			6 : BBRY 10.91 , in 896 milliseconds
			7 : SIRI 3.51 , in 1549 milliseconds
			8 : ZNGA 2.66 , in 813 milliseconds
			9 : ARCP 8.97 , in 865 milliseconds
			10 : XIV 31.42 , in 849 milliseconds
			11 : FOXA 38.42 , in 793 milliseconds
			12 : TVIX 2.72 , in 808 milliseconds
			13 : YHOO 50.49 , in 824 milliseconds
			14 : HBAN 10.50 , in 828 milliseconds
			15 : AAL 53.58 , in 823 milliseconds
			16 : FTR 6.65 , in 836 milliseconds

			----------------------------------------------------------------------------
			
**How to run :** 

		1. Python : Make sure that you use Python 2.7 and then just type : python multithreaded_stock_quotes.py
		2. C# : See instructions at the end of this readme regarding how to build C# project on Linux ( Mono ) and Windows

**How does Yahoo Finance API work :**

		Yahoo Finance API is a REST API that returns CSV information.
		You need to create a URL to request certain information :
		
		1. Base URL is : http://finance.yahoo.com/d/quotes.csv
		
		2. To specify symbols , you add s argument :
		
			s=MSFT	
			
			This one is for only MSFT symbol. To request more than one symbols :
			
			s=MSFT+AAPL
			
		3. By default, all symbols are the ones listed in US exchanges. 
		If you want to query a symbol from a non-US exchange, you have to find out 
		the exhange code :
		
			s=BARC.L
			
			In this example L stands for London Stock Exchange.
			
		4. You will also need to specify what information you want to retrieve.
		You use f argument for this purpose :
		
				f=ab
				
				This project currently only requests bid and offer per symbol.
				Therefore the engine specifies a for ask and b for bid.
				
		Example URL : You can test the url below in your browser :
		
						http://finance.yahoo.com/d/quotes.csv?s=MSFT&f=nab
						
						This one will request ask and bid for MSFT symbol.