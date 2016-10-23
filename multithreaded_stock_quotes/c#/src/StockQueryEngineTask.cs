using System;               
using System.Net;           //for using WebClient
using System.Diagnostics;   //for using StopWatch
using System.Threading;     //for ManualResetEvent

namespace MultithreadedStockQuotes
{
    class StockQueryEngineTask
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
    }
}