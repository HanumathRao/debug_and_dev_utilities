using System.Net;           // for using WebClient
using System.Collections;   // for IEnumerable

namespace MultithreadedStockQuotes
{
    static class Utility
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

        public static bool IsRunningUnderLinux()
        {
            if (System.Environment.OSVersion.ToString().Contains("Unix"))
            {
                return true;
            }

            return false;
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
}