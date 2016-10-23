using System;
using System.Text;

namespace MultithreadedStockQuotes
{
    class Program
    {
        static int Main(string[] args)
        {
            int num_arguments = args.Length;

            if (num_arguments == 0)
            {
                Console.WriteLine("Please provide a symbols file as argument." + System.Environment.NewLine);
                return 1;
            }

            string input_file = args[0];
            
            StockQueryEngine engine = new StockQueryEngine();
            engine.SetMaxNumberOfThreads(System.Environment.ProcessorCount);

            if (engine.LoadSymbolsFromFile(input_file) == false)
            {
               OnEngineError(ref engine);
               return 2;
            }

            if (Utility.CheckForInternetConnection() == true)
            {
                StockQueryEngineTaskInfo[] results = null;
                if ( engine.Execute() )
                {
                    results = engine.Join();
                }
                else
                {
                    OnEngineError(ref engine);
                    return 3;
                }
				
				Console.ForegroundColor = ConsoleColor.Yellow;
				Console.WriteLine("Execution starting...");

				Console.ForegroundColor = ConsoleColor.Cyan;
                Console.WriteLine("----------------------------------------------------------------------------");
				Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine("Entire execution took " + engine.ExecutionTime + " miliseconds");
                Console.WriteLine("");
                Console.WriteLine("Number of threads fired : " + engine.GetMaxNumberOfThreads());
				Console.ForegroundColor = ConsoleColor.Cyan;
                Console.WriteLine("----------------------------------------------------------------------------");
                Console.WriteLine("");
				
				Console.ForegroundColor = ConsoleColor.Yellow;
                foreach (StockQueryEngineTaskInfo info in results)
                {
					
                    Console.Write(info.ThreadIndex + " : " + info.Symbol + " " + info.Bid + " , in " + info.ExecutionTime + " milliseconds");
                    Console.Write(Environment.NewLine);
                    Console.Write(Environment.NewLine);
                }
				
				Console.ForegroundColor = ConsoleColor.Cyan;
                Console.WriteLine("");
                Console.WriteLine("----------------------------------------------------------------------------");

                if (num_arguments == 2)
                {
                    Utility.ExportToCSV(args[1], results, "#symbol,bid,offer");
                }

                return 0;
            }
            else
            {
                Console.WriteLine("No internet connection.");
                return 4;
            }
        }

        static void OnEngineError(ref StockQueryEngine engine)
        {
            Console.WriteLine("Error occured during engine initalisation : " + System.Environment.NewLine);
            Console.WriteLine(engine.GetLastError());
        }
        
    }
}