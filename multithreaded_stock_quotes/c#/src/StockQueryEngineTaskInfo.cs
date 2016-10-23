namespace MultithreadedStockQuotes
{
    class StockQueryEngineTaskInfo
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
    }
}