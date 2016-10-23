using System;
using System.Threading;     //for using ThreadPool
using System.Diagnostics;   //for using StopWatch

namespace MultithreadedStockQuotes
{
    class StockQueryEngine
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
    }
}