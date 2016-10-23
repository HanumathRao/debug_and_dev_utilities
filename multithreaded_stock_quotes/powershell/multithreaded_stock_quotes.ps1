function initialise_multithreaded_stock_quotes_engine()
{
  $source = @"
            using System;
            using System.Net;           // for using WebClient
            using System.Collections;   // for IEnumerable
            using System.Diagnostics;   // for using StopWatch
            using System.Threading;     // for ManualResetEvent
            
            namespace MultithreadedStockQuotes
            {
                public static class Utility
                {
                    public static bool CheckForInternetConnection()
                    {
                        try
                        {
                            using (var client = new WebClient())
                            using (var stream = client.OpenRead("http://www.google.com"))
                            {
                                return true;
                            }
                        }
                        catch
                        {
                            return false;
                        }
                    }

                    public static void ExportToCSV(string filename, IEnumerable collection, string header)
                    {
                        using (System.IO.StreamWriter file = new System.IO.StreamWriter(filename))
                        {
                            if( header.Length > 0)
                            {
                                file.WriteLine(header);
                            }
                            
                            foreach (var item in collection)
                            {
                                file.WriteLine(item.ToString());
                            }
                        }
                    }
                }
                
                public class StockQueryEngineTaskInfo
                {
                    private int m_thread_index;
                    private string m_symbol;
                    private string m_bid;
                    private string m_offer;
                    private long m_execution_time;
                    private string m_base_url;
                    private string m_url_function;

                    public StockQueryEngineTaskInfo(int thread_index, string symbol, string base_url, string url_function)
                    {
                        m_thread_index = thread_index;
                        m_symbol = symbol;
                        m_base_url = base_url;
                        m_url_function = url_function;
                        m_execution_time = 0;
                    }
                    public int ThreadIndex
                    {
                        get { return m_thread_index; }
                        set { m_thread_index = value; }
                    }

                    public string Symbol
                    {
                        get { return m_symbol; }
                        set { m_symbol = value; }
                    }

                    public string Bid
                    {
                        get { return m_bid; }
                        set { m_bid = value; }
                    }

                    public string Offer
                    {
                        get { return m_offer; }
                        set { m_offer = value; }
                    }

                    public long ExecutionTime
                    {
                        get { return m_execution_time; }
                        set { m_execution_time = value; }
                    }

                    public string BaseUrl
                    {
                        get { return m_base_url; }
                        set { m_base_url = value; }
                    }

                    public string UrlFunction
                    {
                        get { return m_url_function; }
                        set { m_url_function = value; }
                    }

                    public override string ToString()
                    {
                        var ret = m_symbol + "," + m_bid + "," + m_offer;
                        return ret;
                    }
                } // class StockQueryEngineTaskInfo
                
                public class StockQueryEngineTask
                {
                    private ManualResetEvent m_done_flag;
                    private Stopwatch m_watch;

                    public StockQueryEngineTask(ManualResetEvent done_flag)
                    {
                        m_done_flag = done_flag;
                        m_watch = new Stopwatch();
                    }

                    public void ThreadPoolCallback(Object threadContext)
                    {
                        StockQueryEngineTaskInfo thread_info = (StockQueryEngineTaskInfo)threadContext;

                        m_watch.Start();
                        QuerySymbol(thread_info);
                        m_watch.Stop();

                        //Some fields from Yahoo Finance API are returned with \n
                        thread_info.Bid = thread_info.Bid.Replace("\n", "");
                        thread_info.Offer = thread_info.Offer.Replace("\n", "");

                        thread_info.ExecutionTime = m_watch.ElapsedMilliseconds;
                        m_done_flag.Set();
                    }

                    public static void QuerySymbol(StockQueryEngineTaskInfo thread_info)
                    {
                        string csvData;

                        using (WebClient web = new WebClient())
                        {
                            string url = thread_info.BaseUrl + thread_info.Symbol + thread_info.UrlFunction;
                            csvData = web.DownloadString(url);

                            string[] args = csvData.Split(',');
                            
                            thread_info.Offer = args[0];
                            thread_info.Bid = args[1];
                        }
                    }
                } // class StockQueryEngineTask
                
                public class StockQueryEngine
                {
                    public StockQueryEngine()
                    {
                        m_symbols = new System.Collections.Generic.List<string>();
                        m_errors = new System.Collections.Generic.Queue<string>();
                        m_symbols_loaded = false;
                        m_latest_execution_time = 0;
                        m_watch = new Stopwatch();
                    }

                    public void SetMaxNumberOfThreads (int n)
                    {
                        if( n < System.Environment.ProcessorCount)
                        {
                            n = System.Environment.ProcessorCount;
                        }

                        ThreadPool.SetMaxThreads(n, n);
                    }

                    public int GetMaxNumberOfThreads()
                    {
                        int worker_threads=0;
                        int completion_ports=0;
                        ThreadPool.GetMaxThreads(out worker_threads, out completion_ports);
                        return worker_threads;
                    }

                    public long ExecutionTime
                    {
                        get { return m_latest_execution_time; }
                    }

                    public bool LoadSymbolsFromFile(string filename)
                    {
                        try
                        {
                            using (System.IO.StreamReader file = new System.IO.StreamReader(filename))
                            {
                                string line;

                                while ((line = file.ReadLine()) != null)
                                {
                                    if (line.StartsWith("#"))
                                    {
                                        continue;
                                    }

                                    m_symbols.Add(line);
                                }

                                m_symbols_loaded = true;
                            }

                        }
                        catch(Exception e)
                        {
                            m_errors.Enqueue(e.Message);
                        }

                        return m_symbols_loaded;
                    }

                    public string GetLastError()
                    {
                        if (m_errors.Count == 0)
                        {
                            return "";
                        }

                        return m_errors.Dequeue();
                    }

                    public bool Execute()
                    {
                        if (m_symbols_loaded == false)
                        {
                            return false;
                        }

                        try
                        {
                            m_watch.Start();

                            int count_symbols = m_symbols.Count;

                            m_task_done_flags = new ManualResetEvent[count_symbols];
                            m_tasks = new StockQueryEngineTask[count_symbols];
                            m_task_infos = new StockQueryEngineTaskInfo[count_symbols];

                            for (int i = 0; i < count_symbols; i++)
                            {
                                m_task_done_flags[i] = new ManualResetEvent(false);
                                m_tasks[i] = new StockQueryEngineTask(m_task_done_flags[i]);

                                m_task_infos[i] = new StockQueryEngineTaskInfo(i, m_symbols[i], m_base_url, m_url_function);
                                ThreadPool.QueueUserWorkItem(new WaitCallback( m_tasks[i].ThreadPoolCallback), m_task_infos[i]);
                            }
                        }
                        catch (Exception e)
                        {
                            m_errors.Enqueue(e.Message);
                            return false;
                        }

                        return true;
                    }

                    public StockQueryEngineTaskInfo[] Join()
                    {
                        WaitHandle.WaitAll(m_task_done_flags);
                        m_watch.Stop();
                        m_latest_execution_time = m_watch.ElapsedMilliseconds;
                        return m_task_infos;
                    }

                    #region MEMBERS
                    private System.Collections.Generic.List<string> m_symbols;
                    private bool m_symbols_loaded;

                    private const string m_base_url = "http://finance.yahoo.com/d/quotes.csv?s=";
                    private const string m_url_function = "&f=ba";

                    private long m_latest_execution_time;
                    private Stopwatch m_watch;

                    private ManualResetEvent[] m_task_done_flags;
                    private StockQueryEngineTask[] m_tasks;
                    private StockQueryEngineTaskInfo[] m_task_infos;
                    private System.Collections.Generic.Queue<string> m_errors;
                    #endregion
                } // class StockQueryEngine
            }
"@

        
            Add-Type -TypeDefinition $source;
}

function write_message([string]$message)
{
    Write-Host $message -ForegroundColor Cyan
}

function write_info_message([string]$message)
{
    Write-Host $message -ForegroundColor Yellow
}

function write_error_message([string]$message)
{
    Write-Host $message -ForegroundColor Red
}

function on_engine_error($engine)
{
    write_error_message "Engine error occured : $engine.GetLastError()"
    exit -3
}

##################################################################################
#Entry point and initialisations
Clear-Host

initialise_multithreaded_stock_quotes_engine

if( [MultithreadedStockQuotes.Utility]::CheckForInternetConnection() -eq $false )
{
    write_error_message "No internet connection"
    exit -1
}

$apartment_state= [System.Threading.Thread]::CurrentThread.GetApartmentState()
if( $apartment_state.ToString().ToUpper() -eq "STA" )
{
    write_error_message "This script has to be executed in MTA mode. Please use the provided bat file."
    #exit -2
}
##################################################################################
#Get symbols file
write_message "Enter name of symbols file ( Press enter for symbols.txt ) :"
[string]$user_symbols_file = Read-Host
if( $user_symbols_file.Length -eq 0)
{
    $user_symbols_file = "symbols.txt"
}
##################################################################################
#Initialise engine
$engine = New-Object MultithreadedStockQuotes.StockQueryEngine
$engine.SetMaxNumberOfThreads( [System.Environment]::ProcessorCount )

if ($engine.LoadSymbolsFromFile($user_symbols_file) -eq $false)
{
    on_engine_error $engine
}
##################################################################################
#Execute engine
write_info_message "Execution starting..."
if( $engine.Execute() -eq $false )
{
    on_engine_error $engine
}

$results = $engine.Join()
##################################################################################
#Display results
$spent_time = $engine.ExecutionTime
$num_threads = $engine.GetMaxNumberOfThreads()
write_message "----------------------------------------------------------------------------"
write_info_message "Entire execution took ${spent_time} milliseconds"
write_info_message "Number of threads fired : ${num_threads}"
write_message "----------------------------------------------------------------------------"
write_message ""

foreach ( $result in $results )
{
    write_info_message ($result.ThreadIndex.ToString() + " : " + $result.Symbol + " " + $result.Bid + " , in " + $result.ExecutionTime.ToString() + " milliseconds")
}

write_message ""
write_message "----------------------------------------------------------------------------"

write_message "Press any key to continue"
$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
